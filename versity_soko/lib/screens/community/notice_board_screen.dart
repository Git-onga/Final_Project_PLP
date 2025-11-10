import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoticeBoardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> notices;

  const NoticeBoardWidget({super.key, required this.notices});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF7F00FF);
    final secondaryColor = const Color(0xFF00BFFF);
    final accentGreen = const Color(0xFF3CB371);
    final onSurfaceColor = Colors.black87;
    final surfaceColor = Colors.white;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  "Notice Board",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                ),
              ],
            ),
          ),

          // Empty state
          if (notices.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.campaign_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'No notices available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Column(
              children: notices
                  .map((notice) => _NoticeCard(notice: notice))
                  .toList(),
            ),
        ],
      ),
    );
  } // Added missing closing brace for build method
}

class _NoticeCard extends StatelessWidget {
  final Map<String, dynamic> notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF7F00FF);
    final secondaryColor = const Color(0xFF00BFFF);
    final accentGreen = const Color(0xFF3CB371);
    final surfaceColor = Colors.white;
    final onSurfaceColor = Colors.black87;

    final title = notice['title']?.toString() ?? 'Untitled Notice';
    final body = notice['description']?.toString() ?? 'No description available';
    final postedBy = notice['postedBy']?.toString() ?? 'Unknown';
    final priority = notice['priority']?.toString() ?? 'Low';
    final createdAt = notice['created_at'] != null
        ? (notice['created_at'] is DateTime 
            ? notice['created_at'] as DateTime 
            : DateTime.tryParse(notice['created_at'].toString()) ?? DateTime.now())
        : DateTime.now();
    final date = DateFormat('yyyy,MMM, dd').format(createdAt);

    return Semantics(
      button: true,
      label: 'Notice: $title. $priority priority',
      child: GestureDetector(
        onTap: () => _showNoticeDetailDialog(context, notice),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [surfaceColor, surfaceColor],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentGreen,
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.2), accentGreen.withOpacity(0.2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.campaign_outlined, color: primaryColor),
              ),
              const SizedBox(width: 12),

              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [secondaryColor.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            priority,
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoticeDetailDialog(BuildContext context, Map<String, dynamic> notice) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final primaryColor = const Color(0xFF7F00FF);
        final secondaryColor = const Color(0xFF00BFFF);
        final onSurfaceColor = Colors.black87;

        final title = notice['title']?.toString() ?? 'Untitled Notice';
        final body = notice['description']?.toString() ?? 'No description available';
        final postedBy = notice['postedBy']?.toString() ?? 'Unknown';
        final priority = notice['priority']?.toString() ?? 'Low';
        final createdAt = notice['created_at'] != null
            ? (notice['created_at'] is DateTime
                ? notice['created_at'] as DateTime
                : DateTime.tryParse(notice['created_at'].toString()) ?? DateTime.now())
            : DateTime.now();
        final date = DateFormat('MMM d, yyyy – hh:mm a').format(createdAt);

        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 500,
              minWidth: 300,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Posted info and priority
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Posted by: $postedBy',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: onSurfaceColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getPriorityColor(priority).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            priority.toUpperCase(),
                            style: TextStyle(
                              color: _getPriorityColor(priority),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Body text
                    Text(
                      body,
                      style: TextStyle(fontSize: 16, height: 1.5, color: onSurfaceColor),
                    ),

                    const SizedBox(height: 20),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return const Color(0xFF00BFFF);
    }
  }
}