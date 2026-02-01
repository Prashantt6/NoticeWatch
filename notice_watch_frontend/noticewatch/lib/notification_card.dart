import 'package:flutter/material.dart';
import 'package:noticewatch/notice.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.details});

  final Notice details;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/notice', arguments: details);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(style: TextStyle(color: Colors.black), details.title),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                style: TextStyle(color: Colors.grey[800]),
                details.publishedDate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
