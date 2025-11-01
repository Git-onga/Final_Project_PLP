import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  bool _hasUnread = false;

  bool get hasUnread => _hasUnread;

  void setUnread(bool value) {
    _hasUnread = value;
    notifyListeners();
  }

  void markAllAsRead() {
    _hasUnread = false;
    notifyListeners();
  }
}
