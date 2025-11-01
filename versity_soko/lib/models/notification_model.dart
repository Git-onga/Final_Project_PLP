import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? iconName;       // stores the string icon name from Supabase
  final bool isRead;
  final DateTime createdAt;

  // These are computed in-app (not stored in DB)
  IconData get icon => _mapIcon(iconName);
  // Color get iconColor => _mapColor(iconName);

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.iconName,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? iconName,      // stores the string icon name from Supabase
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// ✅ Convert Supabase row → Dart model
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      iconName: json['icon'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// ✅ Convert Dart model → Map (for insert)
  Map<String, dynamic> json() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'icon': iconName,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 🧠 Helper: map icon name string to actual Flutter icon
  static IconData _mapIcon(String? iconName) {
    switch (iconName) {
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'shop':
        return Icons.storefront_outlined;
      case 'offer':
        return Icons.discount_outlined;
      case 'order':
        return Icons.check_circle_outline;
      case 'sales':
        return Icons.flash_on_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  /// 🎨 Helper: map icon color based on icon type
  // static Color _mapColor(String? iconName) {
  //   switch (iconName) {
  //     case 'bell':
  //       return Colors.blueAccent;
  //     case 'shop':
  //       return Colors.green;
  //     case 'warning':
  //       return Colors.redAccent;
  //     case 'message':
  //       return Colors.purple;
  //     case 'info':
  //       return Colors.orange;
  //     default:
  //       return Colors.grey;
  //   }
  // }
}
