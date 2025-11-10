import 'package:flutter/foundation.dart';
import 'package:versity_soko/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  bool _hasUnread = false;
  final List<NotificationModel> _notifications = [];

  bool get hasUnread => _hasUnread;
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  void setUnread(bool value) {
    _hasUnread = value;
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // add newest at top
    _hasUnread = true;
    notifyListeners();
  }

  void markAllAsRead() {
    _hasUnread = false;
    notifyListeners();
  }

  void setNotifications(List<NotificationModel> newList) {
    _notifications
      ..clear()
      ..addAll(newList);
    notifyListeners();
  }
}
