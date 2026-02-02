import 'package:flutter/material.dart';
import 'package:noticewatch/notice.dart';
import 'package:url_launcher/link.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

// TODO : fix the pdf view , for now it only works on android and ios

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final notice = ModalRoute.of(context)!.settings.arguments as Notice;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(style: TextStyle(color: Colors.amber), notice.title),
      ),
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Link(
              uri: Uri.parse(notice.pdfLink),
              builder: (BuildContext context, FollowLink? followLink) {
                return InkWell(
                  onTap: followLink,
                  child: Text('Pdf Link : ${notice.pdfLink}'),
                );
              },
            ),
            Link(
              uri: Uri.parse(notice.viewLink),
              builder: (BuildContext context, FollowLink? followLink) {
                return InkWell(
                  onTap: followLink,
                  child: Text('View Link : ${notice.viewLink}'),
                );
              },
            ),
            PDF().cachedFromUrl(notice.pdfLink),
          ],
        ),
      ),
    );
  }
}
