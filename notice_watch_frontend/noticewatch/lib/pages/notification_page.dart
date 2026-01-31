import 'package:flutter/material.dart';
import 'package:noticewatch/notification_card.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:noticewatch/notice.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notice>? notices;

  Future<void> getNotices() async {
    Uri endPoint = Uri.parse('http://localhost:8000/api/notices/');

    Response response = await get(endPoint);

    List<dynamic> data = jsonDecode(response.body).map((e) {
      return e['title'];
    }).toList();

    setState(() {
      notices = data.map((e) {
        return Notice(title: e);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getNotices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('This is the notifications page')),
      ),
      body: notices == null
          ? Center(child: (CircularProgressIndicator()))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: notices!.map((data) {
                return NotificationCard(details: data);
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          getNotices();
        },
      ),
    );
  }
}
