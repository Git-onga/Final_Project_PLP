import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:versity_soko/models/notification_model.dart';// For color/icon helpers

class NotificationService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch all notifications for the current user
  Future<List<NotificationModel>> fetchNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map((notification) {
        print(response);
        return NotificationModel.fromJson(Map<String, dynamic>.from(notification));
        
      }).toList();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }


  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    try {
      await supabase.from('notifications').update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('notifications').update({'is_read': true}).eq('user_id', user.id);
  }


  /// Insert new notification
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
      });
    } catch (e) {
      print('❌ Error creating notification: $e');
    }
  }
}
