import 'package:flutter/material.dart';
import 'package:noticewatch/pages/notifications_list_page.dart';
import 'package:noticewatch/pages/notice_page.dart';
import 'package:noticewatch/repository.dart';
import 'dart:async';
import 'package:noticewatch/notification_service.dart';

// TODO : Add error handling
// TODO : Add local notifications
// TODO : Only update shared preferences ( notices ) is the server sends new data

Map<String, WidgetBuilder> routes = {
  '/notice': (context) {
    return NoticePage();
  },
};
final service = NoticeService();

void pollServer() async {
  final data = await service.getData();
  await service.writeData(data);
  Future.delayed(Duration(seconds: 5 * 60), pollServer);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService().initNotification();

  pollServer();

  runApp(MaterialApp(routes: routes, home: NotificationPage()));
}
