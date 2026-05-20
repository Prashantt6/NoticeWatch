import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:noticewatch/notice_refresh_hub.dart';
import 'package:noticewatch/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Last FCM token successfully registered with the backend.
const String _deviceTokenSentKey = 'device_token_sent_v1';

String get _baseUrl {
  final value = dotenv.env['BaseUrl'];
  if (value == null || value.isEmpty) {
    throw StateError('BaseUrl is not configured in .env');
  }
  return value;
}

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _firebaseMessaging =
    FirebaseMessaging.instance;

  static const String androidChannelId = 'notice_watch_channel';
  static const String androidChannelName = 'NoticeWatch Notifications';
  static const String androidChannelDescription =
      'Notification channel for NoticeWatch';

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;


  Future<void> initNotification() async {
    if(_isInitialized){
      return;
    }
    
    const initSettingsAndroid=
        AndroidInitializationSettings(
          'ic_notification',
        );

    const initializationSettings = 
      InitializationSettings(
        android: initSettingsAndroid,
      );
    
    await notificationsPlugin.initialize(
      initializationSettings,
    );

    final androidPlugin =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        androidChannelId,
        androidChannelName,
        description: androidChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(channel);
    }

    _isInitialized = true;
  }
  Future<void> initializeFCM() async {

    NotificationSettings settings =
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }

    final String? token = await _firebaseMessaging.getToken();

    if (kDebugMode) {
      debugPrint('FCM token: $token');
    }

    if (token != null) {
      await _registerTokenIfNeeded(token);
    }

    _firebaseMessaging.onTokenRefresh.listen(_registerTokenIfNeeded);
    FirebaseMessaging.onMessage.listen(_handleIncomingFcmMessage);
  }

  /// POST device token only on first register or when FCM token changes.
  Future<void> _registerTokenIfNeeded(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSent = prefs.getString(_deviceTokenSentKey);
    if (lastSent == token) {
      if (kDebugMode) {
        debugPrint('FCM token unchanged — skipping device token POST');
      }
      return;
    }

    final ok = await sendTokenBackend(token);
    if (ok) {
      await prefs.setString(_deviceTokenSentKey, token);
    }
  }

  Future<void> _handleIncomingFcmMessage(RemoteMessage message) async {
    final title =
        message.data['title'] ?? message.notification?.title;
    final body =
        message.data['body'] ?? message.notification?.body;
    if ((title != null && title.toString().isNotEmpty) ||
        (body != null && body.toString().isNotEmpty)) {
      await showNotification(
        title: title?.toString(),
        body: body?.toString(),
      );
    }
    await _refreshNoticesAfterPush();
  }

  /// FCM means backend has new data — fetch once and update local cache.
  Future<void> _refreshNoticesAfterPush() async {
    try {
      final service = NoticeService();
      final remote = await service.getData();
      await service.saveNoticesCache(remote);
      NoticeRefreshHub.instance.requestFetch();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Notice cache refresh after push failed: $e\n$st');
      }
    }
  }

  NotificationDetails getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,

        androidChannelName,
        channelDescription: androidChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,

        ticker: 'ticker',
        icon: 'ic_notification',
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      getNotificationDetails(),
    );
  }

  Future<bool> sendTokenBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/device/token'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (kDebugMode) {
        debugPrint('Device token backend: ${response.statusCode}');
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Failed to send token: $e\n$st');
      }
      return false;
    }
  }
}
