import 'package:flutter/material.dart';
import 'package:noticewatch/pages/notifications_list_page.dart';
import 'package:noticewatch/pages/notice_page.dart';
import 'package:noticewatch/repository.dart';
import 'package:noticewatch/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callBackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    await pollServer();
    print('Ran dispatcher');
    return Future.value(true);
  });
}

Map<String, WidgetBuilder> routes = {
  '/notice': (context) {
    return const NoticePage();
  },
};

final service = NoticeService();

Future<void> pollServer() async {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  final String? storedHash = await asyncPrefs.getString('hash');

  // Hash reported by backend
  final String backendHash = await service.getHash();

  if (backendHash.trim().isEmpty) {
    print('Error fetching hash from server');
    return;
  }

  if (storedHash != null && backendHash == storedHash) {
    print('No new data');
    return;
  }

  // Backend hash differs from what frontend has stored -> fetch notices
  final data = await service.getData();
  if (data.isEmpty) {
    print('No notices data from server');
    return;
  }

  // Compute frontend hash from notices and persist
  final String newFrontendHash = service.computePageHash(data);
  await service.writeData(data);
  await service.writeHash(newFrontendHash);

  // Only show notification if this isn't the very first hash we ever stored
  if (storedHash != null) {
    await NotificationService().showNotification(
      title: 'New Notice',
      body: 'A new notice has been published.',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initNotification();

  await pollServer();

  await Workmanager().initialize(
    callBackDispatcher,
    isInDebugMode: false,
  );

  Workmanager().registerPeriodicTask(
    'pollServer',
    'pollServer',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

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

