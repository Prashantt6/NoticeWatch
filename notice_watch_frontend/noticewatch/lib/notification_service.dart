import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart'as http;

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

    print(
      "Permission: ${settings.authorizationStatus}"
    );

    String? token =
        await _firebaseMessaging.getToken();

    print("FCM TOKEN:");
    print(token);

    if (token!=null){

      await sendTokenBackend(
        token,
      );
    }

    FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    )
    {
      if (message.notification != null) {
        showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      }
    });
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

  Future<void> sendTokenBackend(
    String token,
  )async{
    try{

      final response  = await http.post(
        Uri.parse('$_baseUrl/api/device/token',),

        headers: {
          'Content-Type':
              'application/json'
        },
        body: jsonEncode({
          'token': token
        }),
      );
    print(
      'Backend response: '
      '${response.body}'
    );
    }catch (e){
      print(
        'Failed to send token: $e'
      );
    }
  }
}
