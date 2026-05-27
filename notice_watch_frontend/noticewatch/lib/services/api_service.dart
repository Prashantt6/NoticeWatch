import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String get _baseUrlFromEnv {
  final value = dotenv.env['BaseUrl'];
  if (value == null || value.isEmpty) {
    throw StateError('BaseUrl is not configured in .env');
  }
  return value;
}

/// Lightweight API client used only for version checks and notice fetches.
class ApiService {
  const ApiService();

  /// Fetches the notice version from GET /api/version
  /// Returns `null` on errors.
  Future<int?> fetchNoticeVersion({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final uri = Uri.parse('$_baseUrlFromEnv/api/version');
      final resp = await http.get(uri).timeout(timeout);
      if (resp.statusCode != 200) return null;
      final decoded = jsonDecode(resp.body);
      if (decoded is Map && decoded.containsKey('notice_version')) {
        final v = decoded['notice_version'];
        if (v is int) return v;
        if (v is String) return int.tryParse(v);
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) debugPrint('fetchNoticeVersion failed: $e\n$st');
      return null;
    }
  }

  /// Fetches full notices from GET /api/notices/
  /// Returns empty list on failure.
  Future<List<dynamic>> fetchNotices({Duration timeout = const Duration(seconds: 10)}) async {
    final uri = Uri.parse('$_baseUrlFromEnv/api/notices/');
    try {
      final resp = await http.get(uri).timeout(timeout);
      if (resp.statusCode != 200) {
        throw Exception('fetchNotices: non-200 ${resp.statusCode}');
      }
      final decoded = jsonDecode(resp.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        final list = decoded['results'] ?? decoded['data'];
        if (list is List) return list;
      }
      throw Exception('fetchNotices: unexpected response shape');
    } catch (e, st) {
      if (kDebugMode) debugPrint('fetchNotices failed: $e\n$st');
      // Propagate error to caller so cache is not overwritten by empty list.
      rethrow;
    }
  }
}
