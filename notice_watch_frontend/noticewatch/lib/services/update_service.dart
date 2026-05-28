import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_release_model.dart';

String get _baseUrlFromEnv {
  final value = dotenv.env['BaseUrl'];
  if (value == null || value.isEmpty) {
    throw StateError('BaseUrl is not configured in .env');
  }
  return value;
}

class UpdateService {
  final Dio _dio = Dio();

  Future<AppRelease?> checkForUpdate() async {
    try {
      // Gather package info without blocking UI too long.
      final packageInfo = await PackageInfo.fromPlatform();

      int currentBuild;
      try {
        currentBuild = int.parse(packageInfo.buildNumber);
      } catch (e) {
        // If parsing fails, treat current build as 0 so any valid server
        // version will be considered newer. Avoid throwing here.
        currentBuild = 0;
      }

      // Resolve base URL and form request.
      final baseUrl = _baseUrlFromEnv;
      final url = '$baseUrl/api/app-version';

      final response = await _dio.get(url);

      // Parse response into model.
      final release = AppRelease.fromJson(response.data);

      if (release.versionCode > currentBuild) {
        return release;
      }

      return null;
    } catch (e) {
      // Keep failures silent for production; return null (no update).
      // Use debugPrint to avoid noisy prints in release builds.
      // Caller may log or handle accordingly.
      // We intentionally do not rethrow to avoid crashing startup.
      // Example: debugPrint('UpdateService.checkForUpdate error: $e');
      return null;
    }
  }
}