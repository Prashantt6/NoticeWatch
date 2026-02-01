import 'package:flutter/material.dart';
import 'package:noticewatch/pages/notifications_list_page.dart';
import 'package:noticewatch/pages/notice_page.dart';

Map<String, WidgetBuilder> routes = {
  '/notice': (context) {
    return NoticePage();
  },
};

void main() {
  runApp(MaterialApp(routes: routes, home: NotificationPage()));
}
