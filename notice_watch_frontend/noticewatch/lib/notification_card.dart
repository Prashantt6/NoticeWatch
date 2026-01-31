import 'package:flutter/material.dart';
import 'package:noticewatch/notice.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.details});

  final Notice details;

  @override
  Widget build(BuildContext context) {
    return Card(child: Center(child: Text(details.title)));
  }
}
