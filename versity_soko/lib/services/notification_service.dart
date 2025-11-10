import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:versity_soko/models/notification_model.dart';
import 'package:versity_soko/providers/notification_provider.dart';

class NotificationService {
  final SupabaseClient supabase = Supabase.instance.client;
  final NotificationProvider notificationProvider;

  NotificationService({required this.notificationProvider});

  /// Fetch all notifications for the current user
  Future<List<NotificationModel>> fetchNotifications() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<NotificationModel>((notification) {
        return NotificationModel.fromJson(
          Map<String, dynamic>.from(notification),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
      return [];
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String id) async {
    try {
      await supabase.from('notifications').update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for the current user
  Future<void> markAllAsRead() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);
      notificationProvider.markAllAsRead();
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// Insert a new notification for the current user
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    required String iconName,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('notifications').insert({
        'user_id': user.id,
        'title': title,
        'message': message,
        'type': type,
        'icon_name': iconName,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error creating notification: $e');
    }
  }

  /// Subscribe to real-time notifications for the current user
  void listenForNewNotifications() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final channel = supabase.channel('public:notifications_${user.id}');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            final newNotificationData = payload.newRecord;
            if (newNotificationData != null) {
              final newNotification = NotificationModel.fromJson(
                Map<String, dynamic>.from(newNotificationData),
              );

              // Add to provider and mark as unread
              notificationProvider.addNotification(newNotification);
              notificationProvider.setUnread(true);
            }
          },
        )
        .subscribe();
  }
}
