import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifications = [];
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _notifications = _getMockNotifications();
      _isLoading = false;
    });
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index].isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _notifications.clear();
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  List<NotificationItem> get _filteredNotifications {
    if (_currentFilter == NotificationFilter.all) {
      return _notifications;
    }
    return _notifications
        .where((notification) => notification.type == _currentFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.checklist_outlined),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearAllNotifications,
              tooltip: 'Clear all notifications',
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterSection(),
          
          // Notifications List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: NotificationFilter.values.map((filter) {
            final isSelected = _currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  _getFilterLabel(filter),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _currentFilter = filter;
                  });
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.blue,
                checkmarkColor: Colors.white,
                showCheckmark: true,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ShimmerNotificationItem(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == NotificationFilter.all
                  ? "You're all caught up! Check back later for new notifications."
                  : "No ${_getFilterLabel(_currentFilter).toLowerCase()} notifications.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _filteredNotifications;
    
    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteNotification(_notifications.indexOf(notification));
            },
            child: NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(notification, index),
              onMarkAsRead: () => _markAsRead(_notifications.indexOf(notification)),
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification, int index) {
    _markAsRead(_notifications.indexOf(notification));
    
    // Handle different notification types
    switch (notification.type) {
      case NotificationFilter.order:
        // Navigate to order details
        print('Navigating to order: ${notification.id}');
        break;
      case NotificationFilter.promotion:
        // Navigate to promotion
        print('Navigating to promotion: ${notification.id}');
        break;
      case NotificationFilter.following:
        // Navigate to shop profile
        print('Navigating to shop: ${notification.id}');
        break;
      case NotificationFilter.system:
        // Show system message
        print('Showing system message: ${notification.id}');
        break;
      default:
        break;
    }
  }

  String _getFilterLabel(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.order:
        return 'Orders';
      case NotificationFilter.promotion:
        return 'Promotions';
      case NotificationFilter.following:
        return 'Following';
      case NotificationFilter.system:
        return 'System';
    }
  }

  List<NotificationItem> _getMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: '1',
        title: 'Order Shipped!',
        message: 'Your order #ORD-12345 has been shipped and is on its way.',
        type: NotificationFilter.order,
        timestamp: now.subtract(const Duration(minutes: 5)),
        icon: Icons.local_shipping_outlined,
        iconColor: Colors.green,
        actionText: 'Track Order',
      ),
      NotificationItem(
        id: '2',
        title: 'Summer Sale!',
        message: 'Get 50% off on all summer collection. Limited time offer!',
        type: NotificationFilter.promotion,
        timestamp: now.subtract(const Duration(hours: 2)),
        icon: Icons.discount_outlined,
        iconColor: Colors.orange,
        actionText: 'Shop Now',
      ),
      NotificationItem(
        id: '3',
        title: 'New Product Alert',
        message: 'Infinity Boutique just added new dresses to their collection.',
        type: NotificationFilter.following,
        timestamp: now.subtract(const Duration(hours: 5)),
        icon: Icons.storefront_outlined,
        iconColor: Colors.purple,
        actionText: 'View Shop',
      ),
      NotificationItem(
        id: '4',
        title: 'Order Delivered',
        message: 'Your order #ORD-12344 has been successfully delivered.',
        type: NotificationFilter.order,
        timestamp: now.subtract(const Duration(days: 1)),
        icon: Icons.check_circle_outline,
        iconColor: Colors.blue,
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'App Update Available',
        message: 'A new version of the app is available with exciting features.',
        type: NotificationFilter.system,
        timestamp: now.subtract(const Duration(days: 1)),
        icon: Icons.system_update_outlined,
        iconColor: Colors.grey,
        actionText: 'Update Now',
      ),
      NotificationItem(
        id: '6',
        title: 'Flash Sale!',
        message: 'Flash sale starts in 1 hour! Get ready for amazing deals.',
        type: NotificationFilter.promotion,
        timestamp: now.subtract(const Duration(days: 2)),
        icon: Icons.flash_on_outlined,
        iconColor: Colors.red,
        isRead: true,
      ),
      NotificationItem(
        id: '7',
        title: 'Campus Trends Live',
        message: 'Campus Trends is going live in 15 minutes with new arrivals.',
        type: NotificationFilter.following,
        timestamp: now.subtract(const Duration(days: 3)),
        icon: Icons.video_camera_front_outlined,
        iconColor: Colors.pink,
        isRead: true,
      ),
    ];
  }
}

// Notification Model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationFilter type;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final String? actionText;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    this.actionText,
    this.isRead = false,
  });
}

// Notification Types
enum NotificationFilter {
  all,
  order,
  promotion,
  following,
  system,
}

// Notification Card Widget
class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: notification.isRead ? Colors.white : Colors.blue[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        if (notification.actionText != null)
                          TextButton(
                            onPressed: onTap,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              notification.actionText!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: notification.iconColor,
                              ),
                            ),
                          ),
                        if (!notification.isRead)
                          TextButton(
                            onPressed: onMarkAsRead,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Mark read',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}

// Shimmer Loading Widget
class ShimmerNotificationItem extends StatelessWidget {
  const ShimmerNotificationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            
            // Shimmer Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}