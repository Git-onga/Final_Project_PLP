import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:versity_soko/services/events_registeries_services.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: isDark ? Colors.black : Colors.grey[50],
    appBar: AppBar(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      foregroundColor: Colors.black87,
      automaticallyImplyLeading: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: isDark ? [Color.fromARGB(255, 169, 123, 215), Color.fromARGB(255, 126, 146, 237)] : [Colors.blue[700]!, Colors.purple[600]!] ,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds);
        },
        child: const Text(
          'Activity Hub',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // this will be masked by the gradient
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Orders'),
          Tab(text: 'Events'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: const [
        OrdersTab(),
        EventsTab(),
      ],
    ),
  );
}
}

// ORDERS TAB - Integrated with Supabase
class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('user_orders')
          .select('*, shop_orders(status, total_price, product_id, quantity)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _orders = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching orders: $e');
    }
  }

  Color _getStatusColorFromShopOrder(Map<String, dynamic> order) {
    // Get the shop_orders list
    final shopOrders = order['shop_orders'] as List<dynamic>?;

    // If there are no shop orders, return grey
    if (shopOrders == null || shopOrders.isEmpty) return Colors.grey;

    // Assuming you want the status of the first shop order
    final status = (shopOrders[0] as Map<String, dynamic>)['status'] as String?;

    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today, ${_formatTime(date)}';
      } else if (difference.inDays == 1) {
        return 'Yesterday, ${_formatTime(date)}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = _orders[index];
                  return _buildOrderCard(order);
                },
                childCount: _orders.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'Pending';
    final statusColor = _getStatusColorFromShopOrder(order);
    final totalAmount = order['total_amount'] ?? 0.0;
    final orderId = order['id']?.toString() ?? '';
    final createdAt = order['created_at']?.toString() ?? '';
    final itemsCount = order['items_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
        : [Color(0xFFF1EEF6), Color(0xFFE1E6F4)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${orderId.substring(0, 8)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$itemsCount item${itemsCount != 1 ? 's' : ''}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(createdAt),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KES ${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              if (status.toLowerCase() == 'shipped' || status.toLowerCase() == 'in transit')
                ElevatedButton(
                  onPressed: () {
                    // Track order action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Track Order'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// EVENTS TAB - Integrated with Supabase
class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  // final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _events = [];
  // bool _isLoading = true;
  final _eventService = EventRegistriesService();
  final userId = Supabase.instance.client.auth.currentUser!.id;
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _pastEvents = [];
  bool _loading = false;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }
  Future<void> _loadUserEvents() async {
    setState(() => _loading = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    final result = await _eventService.getUserEventHistory(userId);

    setState(() {
      _upcomingEvents = result['upcoming'] ?? [];
      _pastEvents = result['past'] ?? [];
      // Combine both for fallback use (optional)
      _events = [..._upcomingEvents, ..._pastEvents];
      _loading = false;
    });
  }


  String _formatEventDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatEventTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Color _getEventColor(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return Colors.orange;
      case 'seminar':
        return Colors.blue;
      case 'conference':
        return Colors.purple;
      case 'social':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
Widget build(BuildContext context) {
  if (_loading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_upcomingEvents.isEmpty && _pastEvents.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No events scheduled',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Check back later for upcoming events',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: _loadUserEvents,
    child: CustomScrollView(
      slivers: [
        // Upcoming Events Section
        if (_upcomingEvents.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Upcoming Events',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (_upcomingEvents.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = _upcomingEvents[index];
                  return _buildEventCard(event);
                },
                childCount: _upcomingEvents.length,
              ),
            ),
          ),

        // Past Events Section
        if (_pastEvents.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Past Events',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (_pastEvents.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = _pastEvents[index];
                  return _buildEventCard(event);
                },
                childCount: _pastEvents.length,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildEventCard(Map<String, dynamic> event) {
  final title = event['title']?.toString() ?? 'Untitled Event';
  final description = event['description']?.toString() ?? '';
  final eventDate = event['schedule_day']?.toString() ?? '';
  final eventStartTime = event['start_time']?.toString() ?? '';
  final eventEndTime = event['end_time']?.toString() ?? '';
  final location = event['location']?.toString() ?? '';
  final category = event['category']?.toString() ?? 'General';
  final eventColor = _getEventColor(category);
  final String imageUrl = event['image_url']?.toString() ?? '';

  return FutureBuilder<bool>(
    future: _checkIfRegistered(event['id']),
    builder: (context, snapshot) {
      final isRegistered = snapshot.data ?? false;

      if (snapshot.connectionState == ConnectionState.waiting) {
        // Small loader only for the registration button
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
        : [Color(0xFFF1EEF6), Color(0xFFE1E6F4)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 100,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl), // use your event image URL here
                        fit: BoxFit.cover, // ensures the image covers the container
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description,
                      style: TextStyle(
                          fontSize: 14, color:isDark ? Colors.grey[300]: Colors.grey[700], height: 1.4)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16,color:isDark ? Colors.grey[300]: Colors.grey[700],),
                      const SizedBox(width: 8),
                      Text(_formatEventDate(eventDate),
                          style: TextStyle(
                              fontSize: 14, color:isDark ? Colors.grey[300]: Colors.grey[700],)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time,
                          size: 16, color:isDark ? Colors.grey[300]: Colors.grey[700],),
                      const SizedBox(width: 8),
                      Text('$eventStartTime - $eventEndTime',
                          style: TextStyle(
                              fontSize: 14, color:isDark ? Colors.grey[300]: Colors.grey[700],)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16,color:isDark ? Colors.grey[300]: Colors.grey[700],),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(location,
                            style: TextStyle(
                                fontSize: 14, color:isDark ? Colors.grey[300]: Colors.grey[700],)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Register / Registered button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isRegistered
                          ? null
                          : () async {
                              final userId = Supabase
                                  .instance.client.auth.currentUser?.id;
                              if (userId == null) return;

                              final success =
                                  await _eventService.registerForEvent(
                                userId: userId,
                                eventId: event['id'],
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          '🎉 Registered successfully!')),
                                );
                                setState(() {}); // Refresh button state
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered
                            ? Colors.green[100]
                            : eventColor,
                        foregroundColor: isRegistered
                            ? Colors.green[700]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isRegistered
                            ? 'Registered'
                            : 'Register for Event',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}


  /// Helper function to check if user is registered for event
  Future<bool> _checkIfRegistered(String eventId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return false;

    return await _eventService.isUserRegistered(userId: userId, eventId: eventId);
  }
}