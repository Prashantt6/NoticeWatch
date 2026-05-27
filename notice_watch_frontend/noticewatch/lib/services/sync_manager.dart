import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:noticewatch/notice_refresh_hub.dart';
import 'package:noticewatch/repositories/notice_repository.dart';
import 'package:noticewatch/services/api_service.dart';
import 'package:noticewatch/services/local_cache_service.dart';

/// Sources that can trigger a sync. Different sources may have different cooldowns.
enum SyncSource { startup, resume, fcm, fcmBackground, periodic, manual }

class SyncManager {
  SyncManager._internal() : repository = NoticeRepository.instance;

  static final SyncManager instance = SyncManager._internal();

  final NoticeRepository repository;

  // Prevent concurrent syncs.
  Future<SyncResult>? _ongoingSync;

  // Last trigger times per source to debounce rapid events (e.g., repeated FCM).
  final Map<SyncSource, DateTime> _lastTrigger = {};

  // Cooldowns (seconds) per source.
  final Map<SyncSource, Duration> _cooldowns = {
    SyncSource.fcm: const Duration(seconds: 8),
    SyncSource.fcmBackground: const Duration(seconds: 8),
    SyncSource.resume: const Duration(seconds: 10),
    SyncSource.startup: const Duration(seconds: 2),
    SyncSource.periodic: const Duration(minutes: 30),
    SyncSource.manual: Duration.zero,
  };

  // Minimum interval between two full-version checks triggered by any source.
  final Duration _globalDebounce = const Duration(seconds: 2);
  DateTime? _lastAnyTrigger;
  // Timestamp of the last successful sync (version check completed successfully).
  DateTime? _lastSuccessfulSync;

  /// Request a sync; debounced and coalesced. Returns the SyncResult (or last ongoing result).
  Future<SyncResult?> requestSync({SyncSource source = SyncSource.manual}) async {
    final now = DateTime.now().toUtc();

    // Global tiny debounce to coalesce near-simultaneous triggers.
    if (_lastAnyTrigger != null && now.difference(_lastAnyTrigger!) < _globalDebounce) {
      if (kDebugMode) debugPrint('SyncManager: global debounce — ignoring trigger');
      return _ongoingSync; // may be null
    }
    _lastAnyTrigger = now;

    // Per-source cooldown
    final last = _lastTrigger[source];
    final cooldown = _cooldowns[source] ?? Duration.zero;
    if (last != null && now.difference(last) < cooldown) {
      if (kDebugMode) debugPrint('SyncManager: source $source cooldown — ignoring');
      return _ongoingSync;
    }
    _lastTrigger[source] = now;

    // Lightweight recent-success cooldown to avoid repeated version checks
    // after a recent successful sync. Manual requests bypass this.
    if (source != SyncSource.manual &&
        _lastSuccessfulSync != null &&
        now.difference(_lastSuccessfulSync!) < const Duration(seconds: 15)) {
      if (kDebugMode) debugPrint('SyncManager: recent successful sync — skipping');
      return _ongoingSync;
    }

    // If a sync is in progress, return the ongoing future so callers can await completion.
    if (_ongoingSync != null) {
      if (kDebugMode) debugPrint('SyncManager: sync already in progress — joining');
      return _ongoingSync;
    }

    // Start a new sync and remember the future produced by the helper.
    final Future<SyncResult> future = _performSyncInternal(source);
    _ongoingSync = future;

    // When this run completes, clear _ongoingSync only if it still points
    // to this future (prevents races where a new sync started).
    future.whenComplete(() {
      if (_ongoingSync == future) {
        _ongoingSync = null;
      }
    });

    return _ongoingSync;
  }

  /// Internal helper that performs the actual sync work and handles errors.
  Future<SyncResult> _performSyncInternal(SyncSource source) async {
    try {
      final result = await repository.syncIfNeeded();
      // Record successful sync (version check completed) to avoid immediate
      // repeated syncs. We consider a sync successful if the repository was
      // able to obtain a remote version (remoteVersion != null).
      if (result.remoteVersion != null) {
        _lastSuccessfulSync = DateTime.now().toUtc();
      }
      if (result.changed) {
        NoticeRefreshHub.instance.requestFetch();
      }
      return result;
    } catch (e, st) {
      if (kDebugMode) debugPrint('SyncManager sync failed: $e\n$st');
      return SyncResult(fetched: false, changed: false, remoteVersion: null);
    }
  }

  /// Convenience: attempt sync if last sync older than [maxAge].
  Future<SyncResult?> syncIfStale({Duration maxAge = const Duration(minutes: 30)}) async {
    final last = await repository.cache.getLastSyncTime();
    if (last != null) {
      final age = DateTime.now().toUtc().difference(last);
      if (age < maxAge) {
        if (kDebugMode) debugPrint('SyncManager: cache fresh (age ${age.inMinutes}m) — skipping');
        return null;
      }
    }
    return requestSync(source: SyncSource.periodic);
  }
}
