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
    Uri endPoint = Uri.parse('https://noticewatch.onrender.com/api/notices/');

    Response response = await get(endPoint);

    List<dynamic> data = jsonDecode(response.body);

    setState(() {
      notices = data.map((e) {
        return Notice(
          title: e['title'],
          publishedDate: e['published_date'],
          pdfLink: e['pdf_link'],
          viewLink: e['view_link'],
        );
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
        backgroundColor: Colors.grey[800],
        title: Center(
          child: Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.amber,
            ),
            'Notifications',
          ),
        ),
      ),
      backgroundColor: Colors.grey,
      body: notices == null
          ? Center(child: (CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: notices!.map((data) {
                  return NotificationCard(details: data);
                }).toList(),
              ),
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
