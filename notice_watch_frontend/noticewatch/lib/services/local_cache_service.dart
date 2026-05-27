import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String _noticesCacheKey = 'notices_cache_v1';
const String _noticeVersionKey = 'notices_version_v1';
const String _lastSyncKey = 'notices_last_sync_v1';

/// Simple local cache service built on top of SharedPreferences.
/// Keeps a single JSON blob for notices plus lightweight metadata.
/// Adds a lightweight in-memory cache to avoid repeated disk reads.
class LocalCacheService {
  LocalCacheService();

  // In-memory cached raw JSON for notices. Kept minimal to avoid re-parsing.
  String? _cachedNoticesRaw;
  // In-memory decoded JSON to avoid repeated jsonDecode calls.
  List<dynamic>? _decodedCache;
  int? _cachedVersion;
  DateTime? _cachedLastSync;
  // Cached SharedPreferences instance to avoid repeated async lookups.
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<dynamic>?> loadCachedNotices() async {
    // Return decoded in-memory cache if available
    if (_decodedCache != null) return _decodedCache;

    // Memory-first raw string; decode once and cache decoded value
    final raw = await _getCachedNoticesRaw();
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _decodedCache = decoded;
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getCachedNoticesRaw() async {
    if (_cachedNoticesRaw != null) return _cachedNoticesRaw;
    final prefs = await _getPrefs();
    final raw = prefs.getString(_noticesCacheKey);
    if (raw != null && raw.isNotEmpty) {
      _cachedNoticesRaw = raw;
      return raw;
    }
    return null;
  }

  /// Returns raw cached JSON (may be null).
  Future<String?> getCachedRaw() => _getCachedNoticesRaw();

  /// Save only when data changed to avoid unnecessary disk writes.
  Future<void> saveNoticesCache(List<dynamic> data) async {
    final encoded = jsonEncode(data);
    final prefs = await _getPrefs();
    // Prefer in-memory raw cache for fast equality check to avoid a disk read.
    String? existing = _cachedNoticesRaw;
    if (existing == null) {
      existing = prefs.getString(_noticesCacheKey);
    }

    if (existing != null && existing == encoded) {
      // No change — keep in-memory and skip write
      _cachedNoticesRaw = existing;
      _decodedCache = data;
      return;
    }

    await prefs.setString(_noticesCacheKey, encoded);
    _cachedNoticesRaw = encoded;
    _decodedCache = data;
  }

  Future<bool> hasNoticesCache() async {
    final raw = await _getCachedNoticesRaw();
    return raw != null;
  }

  Future<int?> getCachedVersion() async {
    // Memory-first
    if (_cachedVersion != null) return _cachedVersion;
    final prefs = await _getPrefs();
    if (!prefs.containsKey(_noticeVersionKey)) return null;
    final v = prefs.getInt(_noticeVersionKey);
    _cachedVersion = v;
    return v;
  }

  Future<void> setCachedVersion(int version) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_noticeVersionKey, version);
    _cachedVersion = version;
  }

  Future<DateTime?> getLastSyncTime() async {
    if (_cachedLastSync != null) return _cachedLastSync;
    final prefs = await _getPrefs();
    final raw = prefs.getString(_lastSyncKey);
    if (raw == null) return null;
    try {
      final dt = DateTime.parse(raw);
      _cachedLastSync = dt;
      return dt;
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastSyncTime(DateTime dt) async {
    final prefs = await _getPrefs();
    await prefs.setString(_lastSyncKey, dt.toUtc().toIso8601String());
    _cachedLastSync = dt;
  }

  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    await prefs.remove(_noticesCacheKey);
    await prefs.remove(_noticeVersionKey);
    await prefs.remove(_lastSyncKey);
    _cachedNoticesRaw = null;
    _cachedVersion = null;
    _cachedLastSync = null;
    _decodedCache = null;
  }
}
