import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

String get _baseUrl {
  final value = dotenv.env['BaseUrl'];
  if (value == null || value.isEmpty) {
    throw StateError('BaseUrl is not configured in .env');
  }
  return value;
}

/// Persisted JSON list from `/api/notices/` (same shape as API).
const String _noticesCacheKey = 'notices_cache_v1';

class NoticeService {
  Future<List<dynamic>> getData() async {
    final Uri endPoint = Uri.parse('$_baseUrl/api/notices/');

    final Response response = await get(endPoint);

    if (response.statusCode != 200) {
      return [];
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final list = decoded['results'] ?? decoded['data'];
      if (list is List) return list;
    }

    return [];
  }

  /// True after we have ever saved a cache (including empty list `[]`).
  Future<bool> hasNoticesCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_noticesCacheKey);
  }

  /// Returns decoded list or `null` if missing / invalid.
  Future<List<dynamic>?> loadCachedNotices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_noticesCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  Future<void> saveNoticesCache(List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_noticesCacheKey, jsonEncode(data));
  }
}
