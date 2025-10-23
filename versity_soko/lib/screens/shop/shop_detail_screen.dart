import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/shop_model.dart' hide ShopHelper;
import '../../core/utils/shop_helper.dart'; // We'll create this helper

class ShopDetailScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isExpanded = false;

  // Mock data for shop details (in real app, this would come from API)
  final Map<String, dynamic> _shopDetails = {
    'coverImage': 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400',
    'logo': 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=200',
    'phone': '+1 (555) 123-4567',
    'email': 'contact@shop.com',
    'address': '123 University Avenue, Campus Town',
    'workingHours': 'Mon-Fri: 9:00 AM - 6:00 PM, Sat: 10:00 AM - 4:00 PM',
    'delivery': true,
    'pickup': true,
    'returns': true,
    'warranty': false,
    'installation': false,
    'deliveryAreas': 'Campus and surrounding areas',
    'productCount': 45,
    'orderCount': 1234,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    // In real app, call API to follow/unfollow shop
  }

  void _contactShop() async {
    final url = 'tel:${_shopDetails['phone']}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _messageShop() async {
    final url = 'sms:${_shopDetails['phone']}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _emailShop() async {
    final url = 'mailto:${_shopDetails['email']}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareShop() {
    // Implement share functionality
    print('Sharing shop: ${widget.shop.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Shop Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildShopHeader(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: _shareShop,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _showMoreOptions,
              ),
            ],
          ),

          // Shop Details and Tabs
          SliverToBoxAdapter(
            child: _buildShopDetails(),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildAboutTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button for Quick Actions
      floatingActionButton: FloatingActionButton(
        onPressed: _contactShop,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat_outlined),
      ),
    );
  }

  Widget _buildShopHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover Image
        Image.network(
          _shopDetails['coverImage'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.store, size: 60, color: Colors.grey),
            );
          },
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Shop Logo and Basic Info
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Shop Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    _shopDetails['logo'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.store, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Shop Name and Basic Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.shop.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (ShopHelper.isVerified(widget.shop))
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 12, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ShopHelper.getCategory(widget.shop),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          widget.shop.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.shop.reviewCount} reviews)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
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
      ],
    );
  }

  Widget _buildShopDetails() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Follow Button and Stats
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.grey[100] : Colors.blue,
                    foregroundColor: _isFollowing ? Colors.grey[700] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_isFollowing ? 'Following' : 'Follow Shop'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _contactShop,
                icon: const Icon(Icons.phone_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                ),
              ),
              IconButton(
                onPressed: _messageShop,
                icon: const Icon(Icons.message_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Shop Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Followers', ShopHelper.getFollowerCount(widget.shop)),
              _buildStatItem('Products', _shopDetails['productCount']),
              _buildStatItem('Orders', _shopDetails['orderCount']),
              _buildStatItem('Rating', widget.shop.rating.toStringAsFixed(1)),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Description with Read More
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.shop.description,
                maxLines: _isExpanded ? null : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              if (widget.shop.description.length > 150)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    _isExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Contact Information
          _buildContactInfo(),

          const SizedBox(height: 16),

          // Services & Delivery
          _buildServicesInfo(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.location_on_outlined, _shopDetails['address']),
        _buildInfoRow(Icons.phone_outlined, _shopDetails['phone']),
        _buildInfoRow(Icons.email_outlined, _shopDetails['email']),
        _buildInfoRow(Icons.access_time_outlined, _shopDetails['workingHours']),
      ],
    );
  }

  Widget _buildServicesInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services & Delivery',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_shopDetails['delivery'] == true)
              _buildServiceChip('🚚 Delivery', Colors.green),
            if (_shopDetails['pickup'] == true)
              _buildServiceChip('🏪 Pickup', Colors.blue),
            if (_shopDetails['returns'] == true)
              _buildServiceChip('↩️ Returns', Colors.orange),
            if (_shopDetails['warranty'] == true)
              _buildServiceChip('🛡️ Warranty', Colors.purple),
            if (_shopDetails['installation'] == true)
              _buildServiceChip('🔧 Installation', Colors.red),
          ],
        ),
        if (_shopDetails['deliveryAreas'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Delivery Areas: ${_shopDetails['deliveryAreas']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildProductsTab() {
    // Mock products data - in real app, this would come from API
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Wireless Earbuds',
        'price': 59.99,
        'image': 'https://images.unsplash.com/photo-1590658165737-15a047b8b5e3?w=200',
        'rating': 4.5,
        'inStock': true,
      },
      {
        'name': 'Phone Case',
        'price': 19.99,
        'image': 'https://images.unsplash.com/photo-1601593346740-925612772716?w=200',
        'rating': 4.2,
        'inStock': true,
      },
      {
        'name': 'Laptop Sleeve',
        'price': 29.99,
        'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
        'rating': 4.7,
        'inStock': true,
      },
      {
        'name': 'Smart Watch',
        'price': 199.99,
        'image': 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=200',
        'rating': 4.8,
        'inStock': false,
      },
    ];
    
    return products.isEmpty
        ? _buildEmptyState('No products available', Icons.inventory_2_outlined)
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutSection(
            'About ${widget.shop.name}',
            widget.shop.description,
          ),
          const SizedBox(height: 24),
          _buildAboutSection(
            'Shop Category',
            ShopHelper.getCategory(widget.shop),
          ),
          const SizedBox(height: 24),
          _buildAboutSection(
            'Tags',
            ShopHelper.getTags(widget.shop).join(', '),
          ),
          const SizedBox(height: 24),
          _buildAboutSection(
            'University',
            widget.shop.university,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    // Mock reviews data - in real app, this would come from API
    final List<Map<String, dynamic>> reviews = [
      {
        'userName': 'Alex Johnson',
        'userAvatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        'rating': 5.0,
        'comment': 'Amazing products and great customer service! Fast delivery and high quality items.',
        'date': '2 weeks ago',
      },
      {
        'userName': 'Sarah Miller',
        'userAvatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
        'rating': 4.0,
        'comment': 'Good quality products but delivery was a bit slow. Overall happy with the purchase.',
        'date': '1 month ago',
      },
      {
        'userName': 'Mike Chen',
        'userAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        'rating': 4.5,
        'comment': 'Reliable shop with good prices. Will definitely order again!',
        'date': '3 weeks ago',
      },
    ];
    
    return reviews.isEmpty
        ? _buildEmptyState('No reviews yet', Icons.reviews_outlined)
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(reviews[index]);
            },
          );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product details
          print('Product tapped: ${product['name']}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                product['image'],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        product['rating'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      if (product['inStock'] == true)
                        Text(
                          'In Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      // else
                        Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review['userAvatar']),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['userName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(review['rating'].toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  review['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review['comment'],
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('Report Shop'),
                onTap: () {
                  Navigator.pop(context);
                  _reportShop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Block Shop'),
                onTap: () {
                  Navigator.pop(context);
                  _blockShop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share Shop'),
                onTap: () {
                  Navigator.pop(context);
                  _shareShop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email Shop'),
                onTap: () {
                  Navigator.pop(context);
                  _emailShop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _reportShop() {
    print('Reporting shop: ${widget.shop.name}');
  }

  void _blockShop() {
    print('Blocking shop: ${widget.shop.name}');
  }
}

// Tab Bar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate({required this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(text: 'Products'),
          Tab(text: 'About'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}