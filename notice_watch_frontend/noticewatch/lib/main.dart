import 'package:flutter/material.dart';
import 'package:noticewatch/pages/notifications_list_page.dart';
import 'package:noticewatch/pages/notice_page.dart';
import 'package:noticewatch/repository.dart';

Map<String, WidgetBuilder> routes = {
  '/notice': (context) {
    return NoticePage();
  },
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = NoticeService();

  final initialData = await service.getData();
  service.writeData(initialData);
  runApp(MaterialApp(routes: routes, home: NotificationPage()));
}
