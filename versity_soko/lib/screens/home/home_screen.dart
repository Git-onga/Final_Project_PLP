import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../home/show_case.dart';
import '../home/following_screen.dart';
import '../profile/profile_screen.dart';
import '../home/notification_screen.dart';
import '../../models/product_model.dart';
import '../../models/event_model.dart';
import '../home/event_details.dart';
import 'package:versity_soko/services/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference eventsRef = FirebaseDatabase.instance.ref().child('events');
  List<EventModel> events = [];
  bool _loading = true;

	@override
	void initState() {
		super.initState();
    _fetchEvents();
		WidgetsBinding.instance.addPostFrameCallback((_) {
		  Provider.of<ProductProvider>(context, listen: false).loadProducts();
		});
	}

  Future<void> _fetchEvents() async {
    try {
      final snapshot = await eventsRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final loadedEvents = data.entries.map((e) {
          return EventModel.fromMap(e.key, Map<String, dynamic>.from(e.value));
        }).toList();

        setState(() {
          events = loadedEvents;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _loading = false;
      });
    }
  }

	@override
	Widget build(BuildContext context) {
		final productProvider = Provider.of<ProductProvider>(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

		return Scaffold(
        
      body: SafeArea(
        child: productProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          scrollDirection: Axis.vertical, 
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            children: [
              // Header section
              _HomeHeadSection(),
              SizedBox(
                height: 15,
              ),
              // Sponser Banner
              OffersBanner(),
              // Event Section
              SizedBox(height: 25,),
               // Following section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Show Case',
                        style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        ),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const FollowingShopsScreen()),
                            );
                          }, 
                          child: Text('Following', style: TextStyle(fontSize: 12))
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Horizontal scrollable stories
                  SizedBox(
                    height: 100, // Fixed height for stories
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(width: 4),
                        ShopStoryItem(
                          shopName: 'Infinity',
                          hasNewContent: true, // Gradient outline for new content
                        ),
                        
                        ShopStoryItem(
                          shopName: 'Nike Store',
                          hasNewContent: true,
                        ),
                        ShopStoryItem(
                          shopName: 'Tech Hub',
                          hasNewContent: true, // No gradient - already seen
                        ),
                        ShopStoryItem(
                          shopName: 'Book World',
                          hasNewContent: false,
                        ),
                        ShopStoryItem(
                          shopName: 'Cafe Brew',
                          hasNewContent: false,
                        ),
                        ShopStoryItem(
                          shopName: 'Style Zone',
                          hasNewContent: true,
                        ),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25,),
              // Events
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  // const SizedBox(height: 16),
                  Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEventCard(events),
                  const SizedBox(height: 16),
                  Text(
                    'Recommended Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Masonry-style grid with vertical spans
                  _buildRegularProductCard(dummyProducts),
                  
                    
                ],
              )
            ],
          ),
        ),
      ) ,
      
    );
	}
	
  Widget _buildEventCard(List<EventModel> events) {
    if (events.isEmpty) {
      return const Center(child: Text("No events available."));
    }
    return SizedBox(
      height: 320, // overall height for each card row
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final event = events[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            },
            child: Container(
              width: 250, // card width for horizontal layout
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          event.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 160,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 140,
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.isFree ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.isFree ? 'FREE' : 'PAID',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.date,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Text Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                event.time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 4,
                                  children: event.categories.take(1).map((cat) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          color: Colors.purple[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (event.ticketLink != null) {
                                    _showBookingDialog(event);
                                  } else {
                                    _showInterestDialog(event);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: event.isFree ? Colors.green : Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  event.isFree ? 'Join' : 'Tickets',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
            ),
          );
        },
      ),
    );
  }


  // Helper methods for dialogs
  void _showBookingDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${event.date}"),
            Text("Time: ${event.time}"),
            Text("Location: ${event.location}"),
            const SizedBox(height: 16),
            Text(
              event.isFree 
                  ? "This is a free event. Would you like to register?"
                  : "Tickets are available for purchase.",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle booking logic
              _showSuccessDialog(event);
            },
            child: Text(event.isFree ? 'Register' : 'Buy Ticket'),
          ),
        ],
      ),
    );
  }

  void _showInterestDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Express Interest'),
        content: Text('Show your interest in "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You\'re interested in ${event.title}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('I\'m Interested'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(EventModel event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          event.isFree 
              ? 'Successfully registered for ${event.title}!'
              : 'Redirecting to ticket purchase...',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 🧩 The post-style product card (Instagram-like layout)
  Widget _buildRegularProductCard(List<Product> products) {
    return Column(
      children: products.map((product) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏬 Shop Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: const NetworkImage(
                            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.shopName, // Use product.shopName
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const FollowingShopsScreen()),
                        );
                      }, 
                      child: Text('Follow', style: TextStyle(fontSize: 12))
                    ),
                    Icon(Icons.more_vert, color: Colors.grey[600]),
                  ],
                ),
              ),
              // 📄 Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    children: [
                      TextSpan(
                        text: "${product.shopName} ", // Use product.shopName
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: product.description, // Use product.description
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 6),

              // 🖼️ Product Image
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl), // Use product.imageUrl
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getTagColor(product.tag), // Use product.tag
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.tag, // Use product.tag
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade300, // Use product.tag
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.price, // Use product.tag
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ❤️ 💬 Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart_checkout_outlined),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border),
                    ),
                  ],
                ),
              ),

              // ❤️ Likes count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  "${product.likes} likes", // Use product.likes
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),

              const SizedBox(height: 6),

              // 💬 View comments
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 14),
              //   child: Text(
              //     "View all ${product.comments} comments", // Use product.comments
              //     style: TextStyle(color: Colors.grey[600], fontSize: 12),
              //   ),
              // ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }).toList(),
    );
  }

	Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'new':
        return Colors.red;
      case 'hot':
        return Colors.orange;
      case 'trending':
        return Colors.purple;
      case 'sale':
        return Colors.green;
      case 'limited':
        return Colors.amber;
      case 'bestseller':
        return Colors.blue;
      case 'popular':
        return Colors.pink;
      case 'eco':
        return Colors.green;
      case 'luxury':
        return Colors.amber;
      case 'organic':
        return Colors.lightGreen;
      case 'modern':
        return Colors.cyan;
      case 'essential':
        return Colors.blueGrey;
      case 'premium':
        return Colors.deepPurple;
      case 'classic':
        return Colors.brown;
      case 'home':
        return Colors.teal;
      case 'tech':
        return Colors.indigo;
      case 'natural':
        return Colors.lightGreen;
      case 'summer':
        return Colors.orange;
      case 'kitchen':
        return Colors.red;
      case 'fitness':
        return Colors.deepOrange;
      case 'accessory':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class ShopStoryItem extends StatelessWidget {

	final String shopName;
	final bool hasNewContent;
	const ShopStoryItem({
		super.key,
		required this.shopName,
		required this.hasNewContent,
	});

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShowcaseScreen()),
        );
      },
      child: Container(
			width: 80,
			margin: const EdgeInsets.symmetric(horizontal: 4.0),
			child: Column(
				children: [
          // Story circle with gradient border
          Stack(
            alignment: Alignment.center,
            children: [
            // Gradient border for new content
            if (hasNewContent)
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color:  Color(0xFF833AB4),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: _buildShopAvatar(),
                    ),
                  ),
                ),
              )
            else
              // Simple border for seen content
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: _buildShopAvatar(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Shop name
          SizedBox(
            width: 70,
            child: Text(
              shopName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Category
          // SizedBox(
          // 	width: 70,
          // 	child: Text(
          // 		category,
          // 		style: TextStyle(
          // 			fontSize: 8,
          // 			color: Colors.grey[600],
          // 		),
          // 		maxLines: 1,
          // 		overflow: TextOverflow.ellipsis,
          // 		textAlign: TextAlign.center,
          // 		),
          // ),
        ],
			),
		),
    );
	}

	Widget _buildShopAvatar() {
		return Container(
		decoration: BoxDecoration(
			shape: BoxShape.circle,
			image: DecorationImage(
			image: NetworkImage(
				'https://picsum.photos/100/100?random=${shopName.hashCode}',
			),
			fit: BoxFit.cover,
			),
		),
		);
	}
}


class _HomeHeadSection extends StatefulWidget {
  const _HomeHeadSection();

  @override
  State<_HomeHeadSection> createState() => _HomeHeadSectionState();
}

class _HomeHeadSectionState extends State<_HomeHeadSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            // Navigate or perform an action
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: 180,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/images/person1.jpeg"),
                    radius: 28,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authService.value.currentUser!.displayName ?? 'Username',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Kirinyaga University",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white24,
                boxShadow:[
                BoxShadow(
                  color: Colors.grey.withOpacity(.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ], 
              ),
              child: IconButton(
                color: Colors.black,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()),);
                }, 
                icon: Icon(
                  Icons.notifications_none_outlined,
                ),
              ),
            ),
            SizedBox(width: 20,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white24,
                boxShadow:[
                BoxShadow(
                  color: Colors.grey.withOpacity(.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ], 
              ),
              child: IconButton(
                color: Colors.black,
                onPressed: () {}, 
                icon: Icon(
                  Icons.menu,
                ),
              ),
            ),
          ],
        )
      ],
    
    );
    
  }
}

class OffersBanner extends StatelessWidget {
  const OffersBanner({super.key});

  // Use a getter returning a list of Widgets so instance methods can be called.
  List<Widget> get banners => [
        _buildBannerCard(
          titleLine1: 'New Semester,',
          titleLine2: 'New Deals!',
          description: 'Get up to 50% off on study essentials',
          image: 'https://picsum.photos/200/150?random=10',
          gradientColors:[ Color(0xFF764BA2),Color(0xFF667EEA),]
        ),
        _buildBannerCard(
          titleLine1: 'Fresh Arrivals,',
          titleLine2: 'Hot Prices!',
          description: 'Shop the latest student gear now',
          image: 'https://picsum.photos/200/150?random=11',
          gradientColors: [Color(0xFF47F347), Color(0xFF005BEA)],
        ),
        _buildBannerCard(
          titleLine1: 'Limited Time,',
          titleLine2: 'Exclusive Offers!',
          description: 'Hurry before stocks run out!',
          image: 'https://picsum.photos/200/150?random=12',
          gradientColors: [Color(0xFF764BA2),Color(0xFF72DE0D) ],
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
      // banners is already a list of Widgets
      items: banners
          .map(
            (widget) => ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: widget,
            ),
          )
          .toList(),
    );
  }

  Widget _buildBannerCard({
    required String titleLine1,
    required String titleLine2,
    required String description,
    required String image,
    List<Color>? gradientColors,
  }) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ??
              const [
                Color(0xFF764BA2),
                Color(0xFF667EEA),
              ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleLine1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      titleLine2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Banner image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

}

