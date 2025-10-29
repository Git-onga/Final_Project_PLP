import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/shimmer_loader.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = false;
  
  final List<Map<String, dynamic>> upcomingEvents = [
    {
      'title': 'Charity Week',
      'date': '3 Oct - 9 Oct, 2025',
      'color': Colors.orange,
      'progress': 0.7,
      'icon': Icons.volunteer_activism,
    },
    {
      'title': 'Tech Summit',
      'date': '15 Oct - 17 Oct, 2025',
      'color': Colors.blue,
      'progress': 0.3,
      'icon': Icons.computer,
    },
    {
      'title': 'Sports Festival',
      'date': '25 Oct - 27 Oct, 2025',
      'color': Colors.green,
      'progress': 0.1,
      'icon': Icons.sports_soccer,
    },
  ];

  final List<Map<String, dynamic>> studentHighlights = [
    {
      'title': 'Design Club: Best Portfolio',
      'description': 'Showcasing innovative digital art and graphic designs from talented students across campus',
      'category': 'Clubs',
      'color': Colors.purple,
      'likes': 24,
    },
    {
      'title': 'Science Fair Winners',
      'description': 'Celebrating outstanding projects in our annual science fair competition',
      'category': 'Academics',
      'color': Colors.blue,
      'likes': 18,
    },
    {
      'title': 'Basketball Championship',
      'description': 'Team Phoenix wins the inter-collegiate basketball tournament',
      'category': 'Sports',
      'color': Colors.orange,
      'likes': 42,
    },
    {
      'title': 'Music Band Performance',
      'description': 'Harmony Crew delivers an unforgettable performance at the auditorium',
      'category': 'Arts',
      'color': Colors.green,
      'likes': 31,
    },
  ];

  final List<Map<String, dynamic>> sampleNotices = [
    {
      "title": "Semester Opening",
      "body": "The new semester officially begins on 23rd October. Ensure all fees are cleared and course registrations are completed by 20th October. Welcome back students!",
      "postedBy": "Administration Office",
      "isOfficial": true,
      "date": DateTime.now().subtract(const Duration(hours: 4)),
    },
    {
      "title": "Flutter Workshop",
      "body": "Join the Tech Club for an exciting Flutter session this Friday in Lab 4. Learn mobile development and build your first app. All skill levels welcome!",
      "postedBy": "Tech Club",
      "isOfficial": false,
      "date": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "title": "Library Maintenance",
      "body": "Central library will be closed for maintenance from 15th to 17th October. Online resources remain accessible. Plan your studies accordingly.",
      "postedBy": "Library Department",
      "isOfficial": true,
      "date": DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  void _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Community feed updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              
              // Market Buzz
              if (!_isLoading) 
                SliverToBoxAdapter(child: _buildMarketBuzz()),
              
              // Upcoming Events
              SliverToBoxAdapter(
                child: _buildUpcomingEvents(),
              ),
              
              // Notice Board
              NoticeBoardWidget(notices: sampleNotices),
              
              // Student Highlights Header
              SliverToBoxAdapter(
                child: _buildHighlightsHeader(),
              ),
              
              // Student Highlights Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: _isLoading 
                  ? _buildHighlightsShimmer()
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildEnhancedHighlightCard(index),
                        childCount: studentHighlights.length,
                      ),
                    ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   currentIndex: 3,
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         Navigator.pushNamed(context, '/home');
      //         break;
      //       case 1:
      //         Navigator.pushNamed(context, '/shops');
      //         break;
      //       case 2:
      //         Navigator.pushNamed(context, '/create');
      //         break;
      //       case 3:
      //         Navigator.pushNamed(context, '/community');
      //         break;
      //       case 4:
      //         Navigator.pushNamed(context, '/message');
      //         break;
      //     }
      //   },
      // ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community Hub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Connect, Share, and Grow',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Semantics(
            button: true,
            label: 'User profile',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketBuzz() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Market Buzz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Semantics(
            button: true,
            label: 'Sponsored content about exclusive student deals',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Sponsored',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Discover Exciting Deals!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Exclusive promotions from local student-run businesses. Don\'t miss out!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle learn more action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Learn More',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (_isLoading) 
            _buildEventsShimmer()
          else if (upcomingEvents.isEmpty)
            _buildEmptyState('No upcoming events', Icons.event)
          else
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...upcomingEvents.map((event) => 
                    _buildEnhancedEventCard(
                      title: event['title'] as String,
                      date: event['date'] as String,
                      color: event['color'] as Color,
                      progress: event['progress'] as double,
                      icon: event['icon'] as IconData,
                    )
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEventCard({
    required String title,
    required String date,
    required Color color,
    required double progress,
    required IconData icon,
  }) {
    return Semantics(
      button: true,
      label: 'Event: $title. Date: $date',
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Event Icon with colored background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Progress bar
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${(progress * 100).toInt()}% registered',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Donate Button
            ElevatedButton(
              onPressed: () {
                _showDonationDialog(title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Donate',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, size: 20, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Student Highlights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            'See All',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHighlightCard(int index) {
    final highlight = studentHighlights[index];
    final color = highlight['color'] as Color;
    final likes = highlight['likes'] as int;
    bool isLiked = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Semantics(
          button: true,
          label: 'Student highlight: ${highlight['title']}',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with overlay
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.photo_library,
                          color: color.withOpacity(0.6),
                          size: 50,
                        ),
                      ),
                      // Like button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isLiked = !isLiked);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : color,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              highlight['title'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Description
                            Text(
                              highlight['description'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        
                        // Footer with category and likes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                highlight['category'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            
                            // Likes count
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.grey[400],
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$likes',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsShimmer() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(3, (index) => 
          Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: ShimmerLoader(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightsShimmer() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => ShimmerLoader(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        childCount: 4,
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDonationDialog(String eventName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support Event'),
        content: Text('Choose your donation amount for "$eventName"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Thank you for supporting $eventName!')),
              );
            },
            child: const Text('Donate \$10'),
          ),
        ],
      ),
    );
  }
}

class NoticeBoardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> notices;

  const NoticeBoardWidget({
    super.key,
    required this.notices,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.campaign, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Notice Board",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 📰 Notices List
          if (notices.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.campaign, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No notices available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return _NoticeCard(notice: notice);
              },
            ),
        ],
      ),
    );
  }
}

// 🪧 Individual Notice Card
class _NoticeCard extends StatelessWidget {
  final Map<String, dynamic> notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    final isOfficial = notice['isOfficial'] ?? false;
    final date = DateFormat('MMM d, yyyy').format(notice['date']);

    return Semantics(
      button: true,
      label: 'Notice: ${notice['title']}. ${isOfficial ? 'Official' : 'Club'} notice',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoticeDetailPage(notice: notice),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOfficial ? Colors.blueAccent : Colors.greenAccent,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              // 🏷️ Status Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isOfficial ? Colors.blue[50] : Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOfficial ? Icons.campaign_outlined : Icons.group_outlined,
                  color: isOfficial ? Colors.blue : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              // 📄 Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notice['body'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOfficial ? Colors.blue[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isOfficial ? 'Official' : 'Club',
                            style: TextStyle(
                              color: isOfficial ? Colors.blue : Colors.green,
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
}

// 📄 Detailed Notice Page
class NoticeDetailPage extends StatelessWidget {
  final Map<String, dynamic> notice;

  const NoticeDetailPage({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final isOfficial = notice['isOfficial'] ?? false;
    final date = DateFormat('MMM d, yyyy – hh:mm a').format(notice['date']);

    return Scaffold(
      appBar: AppBar(
        title: Text(notice['title']),
        backgroundColor: isOfficial ? Colors.blueAccent : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOfficial ? Colors.blue[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isOfficial ? Icons.campaign : Icons.group,
                    color: isOfficial ? Colors.blue : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Posted by: ${notice['postedBy']}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Notice Body
            Text(
              notice['body'],
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Share functionality
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Notice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOfficial ? Colors.blueAccent : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}