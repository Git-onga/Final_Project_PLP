import 'package:flutter/material.dart';

class Activity {
  final IconData icon;
  final String title;
  final DateTime time;
  final Color color;

  Activity({
    required this.icon,
    required this.title,
    required this.time,
    required this.color,
  });
}
