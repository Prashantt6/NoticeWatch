import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noticewatch/pages/notifications_list_page.dart';
import 'package:noticewatch/pages/notice_page.dart';
import 'package:noticewatch/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Map<String, WidgetBuilder> routes = {
  '/notice': (context) {
    return const NoticePage();
  },
};

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final notificationService = NotificationService();
  await notificationService.initNotification();

  final notification = message.notification;
  final title =
      message.data['title'] ?? notification?.title ?? 'NoticeWatch';
  final body =
      message.data['body'] ?? notification?.body ?? '';
  await notificationService.showNotification(
    title: title,
    body: body,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final notificationservice = 
        NotificationService();

  await notificationservice.initNotification();
  await notificationservice.initializeFCM();



  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoticeWatch',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E293B),
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ),
      routes: routes,
      home: const NotificationPage(),
    ),
  );
}

