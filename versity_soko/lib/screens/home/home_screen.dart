import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:versity_soko/providers/notification_provider.dart';
import 'package:versity_soko/services/notification_service.dart';
import 'package:versity_soko/services/show_case_service.dart';
import '../home/show_case.dart';
import '../home/following_screen.dart';
import '../profile/profile_screen.dart';
import '../home/notification_screen.dart';
import '../../models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/database_service.dart';
import '../../services/retrieve_event_details.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final RetrieveEventDetails _eventService = RetrieveEventDetails();
  final ShowCaseService _showCaseService = ShowCaseService();
  final ScrollController _scrollController = ScrollController();

  List<EventModel> events = [];
  List<EventModel> currentWeekEvents = [];
  List<Map<String, dynamic>> studentHighlights = [];
  bool _loading = true;
  bool _showHeader = true;
  double _lastScrollOffset = 0;
  String? userName;
  String? _profileImage;
  late Future<List<Map<String, dynamic>>> _showcaseFuture;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _showcaseFuture = _fetchShowCase();
    _fetchUserProfile();
    _fetchHighlightDetails();
    _setupScrollListener();
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final service = NotificationService(notificationProvider: provider);
    service.listenForNewNotifications();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final currentOffset = _scrollController.offset;

      if (currentOffset > _lastScrollOffset && currentOffset > 100) {
        if (_showHeader) setState(() => _showHeader = false);
      } else if (currentOffset < _lastScrollOffset && currentOffset <= 100) {
        if (!_showHeader) setState(() => _showHeader = true);
      }

      _lastScrollOffset = currentOffset;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchShowCase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final showcases = await _showCaseService.fetchShowcases(user.id);
      return showcases;
    } catch (e) {
      print('❌ Error fetching showcases: $e');
      return [];
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final fetchedEvents = await _eventService.getWeekEvents();
      setState(() {
        events = fetchedEvents;
        currentWeekEvents = getCurrentWeekEvents(fetchedEvents);
        _loading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() => _loading = false);
    }
  }

  List<EventModel> getCurrentWeekEvents(List<EventModel> events) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return events.where((event) {
      final eventDate = DateTime.parse(event.scheduleDate);
      return eventDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          eventDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _fetchUserProfile() async {
    final dbService = DatabaseService();
    final authService = AuthService();

    try {
      final name = await dbService.loadName();
      final data = await authService.fetchUserProfile();

      setState(() {
        userName = name?['name'] as String?;
        _profileImage = data?['avatar_url'] as String?;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Failed to load profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchHighlightDetails() async {
    try {
      final response = await supabase
          .from('student_highlights')
          .select('*')
          .order('created_at', ascending: false);

      final highlights = (response as List<dynamic>)
          .map<Map<String, dynamic>>((item) => {
                'id': item['id'],
                'title': item['title'] ?? 'Untitled Highlight',
                'description': item['description'] ?? '',
                'image_url': item['image_url'] ?? 'https://picsum.photos/200?random=7',
                'category': item['category'] ?? 'General',
                'likes': item['likes'] ?? 0,
                'comment_count': item['comment_count'] ?? 0,
                'created_at': DateTime.parse(item['created_at']),
              })
          .toList();

      setState(() => studentHighlights = highlights);
    } catch (e) {
      print('Error fetching highlight details: $e');
    }
  }

  String getGreetingTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  void _navigateToHighlightDetail(Map<String, dynamic> highlight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HighlightDetailScreen(highlight: highlight),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'clubs':
        return Colors.purple;
      case 'academics':
        return Colors.blue;
      case 'sports':
        return Colors.orange;
      case 'arts':
        return Colors.green;
      case 'research':
        return Colors.indigo;
      case 'community':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProfileSection(theme),
              _buildNotificationIndicator(theme),
            ],
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildShowCaseSection(theme, brightness)),
                SliverToBoxAdapter(child: _buildHighlightsHeader(theme)),
                if (studentHighlights.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildHighlightPost(studentHighlights[index], theme, brightness),
                      childCount: studentHighlights.length,
                    ),
                  )
                else
                  SliverToBoxAdapter(child: _buildEmptyHighlights(theme, brightness)),
              ],
            ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    final brightness = theme.brightness;
    final bgGradient = brightness == Brightness.dark
        ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
        : [Color(0xFFF1EEF6), Color(0xFFE1E6F4)];

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: 180,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: bgGradient),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: _profileImage != null && _profileImage!.isNotEmpty
                  ? NetworkImage(_profileImage!)
                  : null,
              child: _profileImage == null || _profileImage!.isEmpty
                  ? Icon(Icons.person, size: 28, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName ?? 'User Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                Text(
                  "Good ${getGreetingTime()}",
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIndicator(ThemeData theme) {
    final hasUnread = context.watch<NotificationProvider>().hasUnread;
    final brightness = theme.brightness;
    final bgGradient = brightness == Brightness.dark
        ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
        : [Color(0xFFF1EEF6), Color(0xFFE1E6F4)];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: bgGradient),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(brightness == Brightness.dark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onBackground),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          if (hasUnread)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  // The other widgets (_buildShowCaseSection, _buildHighlightsHeader, _buildHighlightPost, _buildEmptyHighlights) should be updated similarly to use theme colors and brightness for cards, text, backgrounds, and gradients.
  // For brevity, they can follow the pattern above: replace hardcoded colors with theme.colorScheme or conditional colors based on brightness.
  // Show Case Section
Widget _buildShowCaseSection(ThemeData theme, Brightness brightness) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Show Case',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: brightness == Brightness.dark
                    ? Colors.blueGrey.shade700
                    : Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FollowingShopsScreen()),
                  );
                },
                child: Text(
                  'Following',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _showcaseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No showcases available.',
                    style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
                  ),
                );
              }

              final showcases = snapshot.data!;
              final Map<String, List<Map<String, dynamic>>> groupedShowcases = {};

              for (final show in showcases) {
                final shop = show['shops'];
                final shopId = shop?['id'] ?? show['shop_id'];
                if (shopId == null) continue;
                groupedShowcases.putIfAbsent(shopId, () => []).add(show);
              }

              final groupedEntries = groupedShowcases.entries.toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: groupedEntries.length,
                itemBuilder: (context, index) {
                  final entry = groupedEntries[index];
                  final shopShowcases = entry.value;
                  final shop = shopShowcases.first['shops'];
                  final shopName = shop?['name'] ?? 'Unnamed';
                  final shopImage = shop?['image_url'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowcaseViewerScreen(
                            showcases: shopShowcases,
                            initialIndex: 0,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4CAF50),
                                  Color(0xFF2196F3),
                                  Color(0xFF9C27B0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.white,
                              backgroundImage: shopImage != null ? NetworkImage(shopImage) : null,
                              child: shopImage == null
                                  ? Icon(Icons.store, size: 30, color: theme.colorScheme.onBackground)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 70,
                            child: Text(
                              shopName,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

// Highlights Header
Widget _buildHighlightsHeader(ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: Text(
      'Student Highlights',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onBackground,
      ),
    ),
  );
}

// Highlight Post
Widget _buildHighlightPost(Map<String, dynamic> highlight, ThemeData theme, Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? const [Color(0xFF1E1A33), Color(0xFF2C254A)] // dark mode gradient
            : const [Color.fromARGB(255, 241, 238, 246), Color.fromARGB(255, 225, 230, 244)], // light mode gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => _navigateToHighlightDetail(highlight),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: Image.network(
              highlight['image_url'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip
                if (highlight['category'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(highlight['category']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getCategoryColor(highlight['category']).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      highlight['category'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(highlight['category']),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Title
                Text(
                  highlight['title'] ?? 'Untitled Highlight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  highlight['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Engagement Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_border, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('${highlight['likes'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(width: 16),
                        Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('${highlight['comment_count'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                    Text(_formatDate(highlight['created_at']), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Empty Highlights
Widget _buildEmptyHighlights(ThemeData theme, Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[900] : Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
    ),
    child: Column(
      children: [
        Icon(Icons.highlight_off, size: 50, color: isDark ? Colors.grey[600] : Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'No highlights yet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Check back later for student highlights',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
        ),
      ],
    ),
  );
}
}

// Highlight Detail Screen (unchanged, optional: apply theme for background/text)
class HighlightDetailScreen extends StatelessWidget {
  final Map<String, dynamic> highlight;

  const HighlightDetailScreen({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Highlight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              highlight['image_url'],
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight['title'] ?? 'Untitled Highlight',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    highlight['description'] ?? '',
                    style: TextStyle(fontSize: 16, height: 1.5, color: theme.colorScheme.onBackground.withOpacity(0.8)),
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
