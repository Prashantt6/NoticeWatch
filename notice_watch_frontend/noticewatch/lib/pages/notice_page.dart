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
        title: Text(
          notice.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.amber[300],
                ),
                const SizedBox(width: 8),
                Text(
                  notice.publishedDate,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Link(
              uri: Uri.parse(notice.pdfLink),
              builder: (BuildContext context, FollowLink? followLink) {
                return ElevatedButton.icon(
                  onPressed: followLink,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open PDF in browser'),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PDF().cachedFromUrl(
                  notice.pdfLink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
