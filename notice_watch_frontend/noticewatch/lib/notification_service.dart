import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _firebaseMessaging =
    FirebaseMessaging.instance;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;


  Future<void> initNotification() async {
    if(_isInitialized){
      return;
    }
    
    const initSettingsAndroid=
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );

    const initializationSettings = 
      InitializationSettings(
        android: initSettingsAndroid,
      );
    
    await notificationsPlugin.initialize(
      initializationSettings,
    );

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

    FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ){

      showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
    });
  }

  NotificationDetails getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'update_notification_details',
        'Update Notification',
        channelDescription: 'Update Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
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
}
