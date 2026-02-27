import 'package:flutter/material.dart';
import 'package:noticewatch/notification_card.dart';
import 'dart:async';
import 'dart:convert';
import 'package:noticewatch/notice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noticewatch/notification_service.dart';
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
  Timer? _pollTimer;

  Future<void> getNotices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

      // Frontend-stored hash
      final String? storedHash = await asyncPrefs.getString('hash');

      // Backend-reported hash
      final String backendHash = await _service.getHash();

      if (backendHash.trim().isEmpty) {
        // Backend error, just show cached data if available
        final String? rawData = await asyncPrefs.getString('notices');
        if (rawData != null) {
          final data = jsonDecode(rawData);
          setState(() {
            notices = (data as List).map<Notice>((e) {
              return Notice(
                title: e['title'],
                publishedDate: e['published_date'],
                pdfLink: e['pdf_link'],
              );
            }).toList();
            _isLoading = false;
            _error = 'Unable to check for new notices right now.';
          });
        } else {
          setState(() {
            notices = [];
            _isLoading = false;
            _error = 'Unable to load notices right now.';
          });
        }
        return;
      }

      if (storedHash != null && backendHash == storedHash) {
        // No new data, just load from cache if possible
        final String? rawData = await asyncPrefs.getString('notices');
        if (rawData != null) {
          final data = jsonDecode(rawData);
          setState(() {
            notices = (data as List).map<Notice>((e) {
              return Notice(
                title: e['title'],
                publishedDate: e['published_date'],
                pdfLink: e['pdf_link'],
              );
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            notices = [];
            _isLoading = false;
            _error = 'No notices available yet.';
          });
        }
        return;
      }

      // Hash differs or no stored hash -> fetch notices
      final remote = await _service.getData();
      if (remote.isEmpty) {
        setState(() {
          notices = [];
          _isLoading = false;
          _error = 'No notices available yet.';
        });
        return;
      }

      // Compute and persist frontend hash & data
      final String newFrontendHash = _service.computePageHash(remote);
      await _service.writeData(remote);
      await _service.writeHash(newFrontendHash);

      // Show notification only if we've seen data before
      if (storedHash != null) {
        await NotificationService().showNotification(
          title: 'New Notice',
          body: 'A new notice has been published.',
        );
      }

      setState(() {
        notices = remote.map<Notice>((e) {
          return Notice(
            title: e['title'],
            publishedDate: e['published_date'],
            pdfLink: e['pdf_link'],
          );
        }).toList();
        _isLoading = false;
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
    _pollTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => getNotices(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
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
