import 'package:flutter/material.dart';

class AttendeeAvatars extends StatelessWidget {
  final int attendeeCount;

  const AttendeeAvatars({super.key, required this.attendeeCount});

  @override
  Widget build(BuildContext context) {
    final sampleAvatars = [
      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
    ];

    return Stack(
      children: [
        for (int i = 0; i < sampleAvatars.length; i++)
          Positioned(
            left: i * 25.0,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(sampleAvatars[i]),
              backgroundColor: Colors.grey[300],
            ),
          ),
        if (attendeeCount > 4)
          Positioned(
            left: 100.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[500],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '+${attendeeCount - 4}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}