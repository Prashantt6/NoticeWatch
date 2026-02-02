import 'package:flutter/material.dart';
import 'package:noticewatch/notification_card.dart';
import 'dart:convert';
import 'package:noticewatch/notice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notice>? notices;

  Future<void> getNotices() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

    final rawData = await asyncPrefs.getString('notices');
    if (rawData == null) {
      print('Data Not found');
    } else {
      final data = jsonDecode(rawData);

      setState(() {
        notices = data.map<Notice>((e) {
          return Notice(
            title: e['title'],
            publishedDate: e['published_date'],
            pdfLink: e['pdf_link'],
            viewLink: e['view_link'],
          );
        }).toList();
      });
    }
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
