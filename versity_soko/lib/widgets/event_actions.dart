import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventActions extends StatelessWidget {
  final bool isInterested;
  final bool isRegistered;
  final VoidCallback onInterestToggle;
  final VoidCallback onShare;
  final VoidCallback onRegister;
  final EventModel event;

  const EventActions({
    super.key,
    required this.isInterested,
    required this.isRegistered,
    required this.onInterestToggle,
    required this.onShare,
    required this.onRegister,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: isInterested ? Icons.favorite : Icons.favorite_border,
          label: 'Interested',
          isActive: isInterested,
          activeColor: Colors.red,
          onTap: onInterestToggle,
        ),
        _buildActionButton(
          icon: Icons.calendar_today,
          label: 'Add to Calendar',
          isActive: false,
          onTap: () {
            // Add to calendar functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to calendar')),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          isActive: false,
          onTap: onShare,
        ),
        _buildActionButton(
          icon: Icons.notifications,
          label: 'Remind',
          isActive: false,
          onTap: () {
            // Set reminder functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder set')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: isActive ? activeColor ?? Colors.blue : Colors.grey[600],
          iconSize: 24,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor ?? Colors.blue : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}