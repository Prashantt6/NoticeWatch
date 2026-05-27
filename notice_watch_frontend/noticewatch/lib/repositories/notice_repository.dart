import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:noticewatch/services/api_service.dart';
import 'package:noticewatch/services/local_cache_service.dart';

/// Repository result indicating whether a fetch occurred and if data changed.
class SyncResult {
  final bool fetched;
  final bool changed;
  final int? remoteVersion;

  SyncResult({required this.fetched, required this.changed, this.remoteVersion});
}

/// Singleton NoticeRepository to ensure single shared cache and consistent state.
class NoticeRepository {
  NoticeRepository._internal({required this.api, required this.cache});

  static final NoticeRepository instance = NoticeRepository._internal(
    api: const ApiService(),
    cache: LocalCacheService(),
  );

  final ApiService api;
  final LocalCacheService cache;

  // Factory constructor removed to enforce singleton usage via `NoticeRepository.instance`.

  Future<List<dynamic>?> getCachedNotices() => cache.loadCachedNotices();

  Future<int?> getCachedVersion() => cache.getCachedVersion();

  Future<bool> hasCache() => cache.hasNoticesCache();

  /// Checks /api/version and only fetches full notices if version changed.
  /// Returns a SyncResult describing what happened.
  Future<SyncResult> syncIfNeeded() async {
    final remoteVersion = await api.fetchNoticeVersion();
    if (remoteVersion == null) {
      return SyncResult(fetched: false, changed: false, remoteVersion: null);
    }

    final localVersion = await cache.getCachedVersion();
    if (localVersion != null && localVersion == remoteVersion) {
      await cache.setLastSyncTime(DateTime.now().toUtc());
      return SyncResult(fetched: false, changed: false, remoteVersion: remoteVersion);
    }

    // Version changed — fetch full notices and update cache.
    try {
      final notices = await api.fetchNotices();
      // If identical to existing cache, skip saving and avoid UI refresh.
      final existingRaw = await cache.getCachedRaw();
      final newRaw = jsonEncode(notices);
      if (existingRaw != null && existingRaw == newRaw) {
        // Only update version and last sync time
        await cache.setCachedVersion(remoteVersion);
        await cache.setLastSyncTime(DateTime.now().toUtc());
        return SyncResult(fetched: true, changed: false, remoteVersion: remoteVersion);
      }

      await cache.saveNoticesCache(notices);
      await cache.setCachedVersion(remoteVersion);
      await cache.setLastSyncTime(DateTime.now().toUtc());

      return SyncResult(fetched: true, changed: true, remoteVersion: remoteVersion);
    } catch (e) {
      // Do not overwrite cache on fetch failures. Preserve previous state.
      return SyncResult(fetched: false, changed: false, remoteVersion: remoteVersion);
    }
  }

  /// Force a full fetch and cache replace (manual refresh).
  /// Returns true if cache was updated.
  Future<bool> forceFetchAndCache() async {
    try {
      final notices = await api.fetchNotices();
      final newRaw = jsonEncode(notices);
      final existingRaw = await cache.getCachedRaw();
      if (existingRaw != null && existingRaw == newRaw) {
        // update version/time as best-effort
        final v = await api.fetchNoticeVersion();
        if (v != null) await cache.setCachedVersion(v);
        await cache.setLastSyncTime(DateTime.now().toUtc());
        return true;
      }

      await cache.saveNoticesCache(notices);
      final v = await api.fetchNoticeVersion();
      if (v != null) await cache.setCachedVersion(v);
      await cache.setLastSyncTime(DateTime.now().toUtc());
      return true;
    } catch (e) {
      // Preserve cache on failure
      return false;
    }
  }
}
