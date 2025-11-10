import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event_model.dart';
import '../../widgets/shimmer_loader.dart';
import '../../services/retrieve_event_details.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;
  final RetrieveEventDetails _eventService = RetrieveEventDetails();

  bool _isLoading = false;
  List<EventModel> events = [];
  List<EventModel> nextWeekEvents = [];
  List<Map<String, dynamic>> sampleNotices = [];

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _simulateLoading();
    _fetchEvents();
    _fetchNotices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  Future<void> _fetchEvents() async {
    try {
      final fetchedEvents = await _eventService.getWeekEvents();
      setState(() {
        events = fetchedEvents;
        nextWeekEvents = _getUpcomingEvents(fetchedEvents);
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _fetchNotices() async {
    try {
      final response = await _supabase
          .from('notice_boards')
          .select('*')
          .order('created_at', ascending: false);

      final notices = (response as List<dynamic>)
          .map<Map<String, dynamic>>((item) => {
                'id': item['id'],
                'title': item['title'] ?? 'Untitled Notice',
                'description': item['description'] ?? '',
                'postedBy': item['posted_by'] ?? 'Unknown',
                'priority': item['priority'] ?? 'low',
                'created_at': DateTime.parse(item['created_at']),
              })
          .toList();

      setState(() {
        sampleNotices = notices;
      });
    } catch (e) {
      print('Error fetching notices: $e');
    }
  }

  List<EventModel> _getUpcomingEvents(List<EventModel> events) {
    final now = DateTime.now();
    return events.where((event) {
      final eventDate = DateTime.parse(event.scheduleDate);
      return !eventDate.isBefore(DateTime(now.year, now.month, now.day));
    }).toList();
  }

  void _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await _fetchEvents();
    await _fetchNotices();
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Community feed updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      // Gradient background
      body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _refreshData(),
            backgroundColor: isDark
                ? Colors.black
                : const Color.fromARGB(255, 225, 230, 244),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildMarketBuzz()),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: isDark ? Colors.white : Colors.black,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Colors.blue,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: "Events"),
                        Tab(text: "Notice Board"),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventsTab(),
                      _buildNoticeBoardTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: isDark
                  ? const [Color.fromARGB(255, 241, 238, 246), Color.fromARGB(255, 225, 230, 244)]
                  : const [Color(0xFF764BA2), Color(0xFF667EEA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            'Community Hub',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              // color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Carousel ----------------
  Widget _buildMarketBuzz() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Buzz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          const OffersBanner(),
        ],
      ),
    );
  }

  // ---------------- Events Tab ----------------
  Widget _buildEventsTab() {
    if (_isLoading) return _buildEventsShimmerVertical();
    if (nextWeekEvents.isEmpty)
      return _buildEmptyState('No upcoming events', Icons.event);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: nextWeekEvents.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final event = nextWeekEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildVerticalEventCard(event),
        );
      },
    );
  }

  Widget _buildVerticalEventCard(EventModel event) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? const Color(0xFF2C254A) : Colors.white,
      child: InkWell(
        onTap: () => _showEventDialog(event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Image.network(
                event.imageUrl.isNotEmpty
                    ? event.imageUrl
                    : 'https://picsum.photos/300/180?random=${event.id}',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark ? const Color(0xFF1E1A33) : Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.event,
                          size: 50, color: isDark ? Colors.white70 : Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: isDark ? Colors.white70 : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatEventDate(event.scheduleDate),
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on,
                          size: 14, color: isDark ? Colors.white70 : Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                              fontSize: 12, color: isDark ? Colors.white70 : Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.isFree
                          ? (isDark ? Colors.green[900] : Colors.green[50])
                          : (isDark ? Colors.blue[900] : Colors.blue[50]),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: event.isFree
                            ? (isDark ? Colors.green : Colors.green)
                            : (isDark ? Colors.blue : Colors.blue),
                      ),
                    ),
                    child: Text(
                      event.isFree ? 'FREE' : 'PAID',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: event.isFree
                            ? (isDark ? Colors.green : Colors.green)
                            : (isDark ? Colors.blue : Colors.blue),
                      ),
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

  Widget _buildEventsShimmerVertical() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: 3,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoader(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C254A) : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- Notice Board Tab ----------------
  Widget _buildNoticeBoardTab() {
    if (_isLoading) return _buildNoticesShimmer();
    if (sampleNotices.isEmpty)
      return _buildEmptyState('No notices', Icons.notifications);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: sampleNotices.length,
      itemBuilder: (context, index) {
        final notice = sampleNotices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildNoticeCard(notice),
        );
      },
    );
  }

  Widget _buildNoticeCard(Map<String, dynamic> notice) {
    final createdAt = notice['created_at'] as DateTime;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C254A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice['title'] ?? 'Untitled Notice',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notice['description'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted by: ${notice['postedBy']}',
                  style: TextStyle(
                      fontSize: 10, color: isDark ? Colors.white70 : Colors.grey),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(createdAt),
                  style: TextStyle(
                      fontSize: 10, color: isDark ? Colors.white70 : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticesShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: 3,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerLoader(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C254A) : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1A33) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? const Color(0xFF2C254A) : Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isDark ? Colors.white54 : Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatEventDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showEventDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C254A) : Colors.white,
        title: Text(event.title,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.calendar_today,
                    _formatEventDate(event.scheduleDate)),
                _buildDetailRow(Icons.access_time,
                    '${event.startTime} - ${event.endTime}'),
                _buildDetailRow(Icons.location_on, event.location),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Sliver AppBar Delegate ----------------
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1E1A33), Color(0xFF2C254A)]
              : const [Color.fromARGB(255, 241, 238, 246), Color.fromARGB(255, 225, 230, 244)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// ---------------- Offers Banner ----------------
class OffersBanner extends StatelessWidget {
  const OffersBanner({super.key});

  List<Widget> get banners => [
        _buildBannerCard(
          titleLine1: 'New Semester,',
          titleLine2: 'New Deals!',
          description: 'Get up to 50% off on study essentials',
          image: 'https://picsum.photos/200/150?random=10',
          gradientColors: const [Color(0xFF764BA2), Color(0xFF667EEA)],
        ),
        _buildBannerCard(
          titleLine1: 'Fresh Arrivals,',
          titleLine2: 'Hot Prices!',
          description: 'Shop the latest student gear now',
          image: 'https://picsum.photos/200/150?random=11',
          gradientColors: const [Color(0xFF47F347), Color(0xFF005BEA)],
        ),
        _buildBannerCard(
          titleLine1: 'Limited Time,',
          titleLine2: 'Exclusive Offers!',
          description: 'Hurry before stocks run out!',
          image: 'https://picsum.photos/200/150?random=12',
          gradientColors: const [Color(0xFF764BA2), Color(0xFF72DE0D)],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 7),
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 16 / 9,
      ),
      items: banners
          .map((widget) => ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: widget,
              ))
          .toList(),
    );
  }

  static Widget _buildBannerCard({
    required String titleLine1,
    required String titleLine2,
    required String description,
    required String image,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titleLine1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    titleLine2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
