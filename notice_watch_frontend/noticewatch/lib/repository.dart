import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Deployed backend base URL (no trailing slash!)
const String kApiBaseUrl = 'https://noticewatch.onrender.com';

class NoticeService {
  // Fetch notices from backend
  Future<List<dynamic>> getData() async {
    final Uri endPoint = Uri.parse('$kApiBaseUrl/api/notices/');

    final Response response = await get(endPoint);

    if (response.statusCode != 200) {
      print('Failed to load notices: ${response.statusCode}');
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

  // Save notices locally (matches NotificationPage reader)
  Future<void> writeData(List<dynamic> data) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString('notices', jsonEncode(data));
  }

  // Compute page hash on frontend from notices list
  String computePageHash(List<dynamic> notices) {
    final hashes = notices
        .map((e) => e['content_hash']?.toString())
        .where((h) => h != null && h.isNotEmpty)
        .cast<String>()
        .toList();

    if (hashes.isEmpty) return '';

    final concatenated = hashes.join('|');
    final digest = sha256.convert(utf8.encode(concatenated));
    return digest.toString();
  }

  // Get hash from backend (supports both ["hash"] and "hash" formats)
  Future<String> getHash() async {
    final Uri endPoint = Uri.parse('$kApiBaseUrl/api/notifier/');

    final Response response = await get(endPoint);

    if (response.statusCode != 200) {
      print('Failed to load hash: ${response.statusCode}');
      return '';
    }

    final body = response.body;
    try {
      final decoded = jsonDecode(body);
      if (decoded is String) {
        return decoded;
      }
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is String) return first;
      }
      if (decoded is Map<String, dynamic>) {
        final value = decoded['hash'] ?? decoded['page_hash'];
        if (value is String) return value;
      }
    } catch (_) {
      // Not JSON, assume raw hash string
      return body.trim();
    }

    return '';
  }

  // Save hash locally (frontend-computed hash)
  Future<void> writeHash(String hash) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString('hash', hash);
  }
}