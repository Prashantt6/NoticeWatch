import 'package:flutter/foundation.dart';

/// Notifies the notices screen to refetch from the API (e.g. after an FCM message).
class NoticeRefreshHub extends ChangeNotifier {
  NoticeRefreshHub._();
  static final NoticeRefreshHub instance = NoticeRefreshHub._();

  void requestFetch() => notifyListeners();
}
