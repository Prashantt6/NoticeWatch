import 'package:flutter/material.dart';
import 'package:noticewatch/notification_card.dart';
import 'package:noticewatch/notice.dart';
import 'package:noticewatch/repository.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notice>? notices;
  bool _isLoading = false;
  String? _error;
  final NoticeService _service = NoticeService();
  Future<void> getNotices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {


      // Hash differs or no stored hash -> fetch notices
      final remote = await _service.getData();

      setState(() {
        notices = remote.map<Notice>((e){
          return Notice(title: e['title'],
           publishedDate: e['published_date'],
            pdfLink: e['pdf_link'],
            );
        }).toList();
        _isLoading= false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load notices. Please try again.';
      });
      debugPrint('Error loading notices: $e');
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
        title: const Text(
          'NoticeWatch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await getNotices();
        },
        child: _isLoading && (notices == null)
            ? const Center(child: CircularProgressIndicator())
            : notices == null || notices!.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 72,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _error ?? 'No notices yet. Pull down to refresh.',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notices!.length,
                    itemBuilder: (context, index) {
                      return NotificationCard(details: notices![index]);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          getNotices();
        },
      ),
    );
  }
}
