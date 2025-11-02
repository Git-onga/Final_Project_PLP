import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/kyosk_provider.dart';
import '../../models/shop_order_model.dart';
import '../../providers/shop_order_provider.dart';
import '../../services/shop_order_service.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool userShowcase = false;
  late final bool hasUserPosted = userShowcase; // Example check
  late final String? showcaseImage = userShowcase?.imageUrl;
  // List<ShopOrderModel> order = [];
  List<ShopOrderWithProductModel> orderAndProducts = [];
  final ShopOrderService _orderService = ShopOrderService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadOrders();
    loadOrdersWithProduct();
  }

  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

  void loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedOrders = await _orderService.fetchShopOrders();
      
      
      // Store the orders in state
      setState(() {
        orderAndProducts = fetchedOrders;
        _isLoading = false;
      });

    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadOrdersWithProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedOrdersWithProducts = await _orderService.fetchShopOrdersWithProducts();
      
      
      // Store the orders in state
      setState(() {
        orderAndProducts = fetchedOrdersWithProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => KioskProvider(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'My Shop Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent, // Make background transparent
          elevation: 0, // Remove shadow if desired
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF764BA2),
                  Color(0xFF667EEA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.check_circle_outline), text: 'Orders'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Products'),
              Tab(icon: Icon(Icons.store), text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildOrderTab(),
            _buildProductsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<KioskProvider>(
      builder: (context, kioskProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSectionHeader('Add Showcases'),
              const SizedBox(height: 16),
              _buildShowCase(),
              const SizedBox(height: 24),

              // Quick Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Today\'s Showcases',
                      value: '45',
                      change: '+5%',
                      icon: Icons.visibility,
                      color: const Color(0xFF00BCD4), // Cyan
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Monthly Revenue',
                      value: '\$2,845',
                      change: '+8%',
                      icon: Icons.attach_money,
                      color: const Color(0xFF2196F3), // Blue
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Followers',
                      value: '1.2K',
                      change: '+23%',
                      icon: Icons.people,
                      color: const Color(0xFF9C27B0), // Purple
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Monthly Orders',
                      value: '156',
                      change: '+12%',
                      icon: Icons.shopping_cart,
                      color: const Color(0xFF4CAF50), // Green
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              _buildSectionHeader('Recent Activity'),
              const SizedBox(height: 16),
              _buildActivityList()
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderTab() {
    // Calculate order counts by status
    final receivedCount = orderAndProducts.length;
    final confirmedCount = orderAndProducts
        .where((order) => order.status.toLowerCase() == 'confirmed')
        .length;
    final cancelledCount = orderAndProducts
        .where((order) => order.status.toLowerCase() == 'cancelled')
        .length;

    return Column(
      children: [
        // Inventory Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[50]!, Colors.blue[50]!],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInventoryStat('Received', '$receivedCount'),
              _buildInventoryStat('Confirmed', '$confirmedCount'),
              _buildInventoryStat('Cancelled', '$cancelledCount'),
            ],
          ),
        ),

        Expanded(
          child: orderAndProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Orders Yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Orders will appear here when customers make purchases',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderAndProducts.length,
                  itemBuilder: (context, index) {
                    final orderItem = orderAndProducts[index];
                    return _buildOrderItem(orderItem);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShowCase() {
    return Container( 
      padding: EdgeInsets.all(16),
      child: Row(
      
        children: [
          GestureDetector(
            onTap: () {
            // Navigate or perform an action
              _showShowCaseOptions();
            }, // Makes the entire container selectable
            child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage('https://picsum.photos/400/600?random=15'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            
          ),
          SizedBox(width: 40),

          // Left side - Status/Avatar or "No post yet" text
          _buildShowCaseStatus(hasUserPosted, showcaseImageUrl: showcaseImage),
          
          const Spacer(),
          
          // Right side - Icon that leads to image picker/text input
          // _buildShowCaseActions(),
        ],
      )
    );
  }

  Widget _buildShowCaseStatus(bool hasUserPosted, {String? showcaseImageUrl}) {
    if (hasUserPosted) {
      // User has posted - show avatar circle
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF833AB4),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundImage: showcaseImageUrl != null
              ? NetworkImage(showcaseImageUrl)
              : const NetworkImage('https://picsum.photos/400/600?random=15'),
          backgroundColor: Colors.grey,
        )
      );
    } else {
      // User hasn't posted - show text
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No post yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Showcase your products here',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
  }


  void _showShowCaseOptions() {
    // This will show a modal bottom sheet with options
    showModalBottomSheet(
      context: context, // Make sure you have context available
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Add to Showcase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.blue),
                title: const Text('Write a Post'),
                onTap: () {
                  Navigator.pop(context);
                  _showTextInput();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Placeholder methods - implement these based on your needs
  Future<void> _pickImageFromGallery() async {
    // Implement image picker logic
    print('Open image gallery');
  }

  Future<void> _takePhoto() async {
    // Implement camera logic
    print('Open camera');
  }

  void _showTextInput() {
    // Implement text input dialog
    print('Show text input');
  }

  Widget _buildProductsTab() {
    return Consumer<KioskProvider>(
      builder: (context, kioskProvider, child) {
        return Column(
          children: [
            // Quick Actions
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      'Add Product',
                      Icons.add_circle_outline,
                      const Color(0xFF4CAF50),
                      () => _showAddProductDialog(context, kioskProvider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Add Service',
                      Icons.miscellaneous_services,
                      const Color(0xFF2196F3),
                      () => _showAddServiceDialog(context, kioskProvider),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        labelColor: const Color(0xFF6C63FF),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF6C63FF),
                        tabs: const [
                          Tab(text: 'Products'),
                          Tab(text: 'Services'),
                          Tab(text: 'Drafts'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildProductsList(kioskProvider),
                          _buildServicesList(kioskProvider),
                          _buildDraftsList(kioskProvider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<KioskProvider>(
      builder: (context, kioskProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Shop Profile Card
              _buildShopProfileCard(),

              const SizedBox(height: 24),

              // Shop Settings
              _buildSectionHeader('Shop Settings'),
              const SizedBox(height: 16),
              _buildSettingsList(),

              const SizedBox(height: 24),

              // Business Hours
              _buildSectionHeader('Business Hours'),
              const SizedBox(height: 16),
              _buildBusinessHours(),

              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButton('Save Changes', Icons.save, const Color(0xFF4CAF50)),
              const SizedBox(height: 12),
              _buildActionButton('Preview Shop', Icons.visibility, const Color(0xFF2196F3)),
            ],
          ),
        );
      },
    );
  }

  // Component Building Methods
  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {'icon': Icons.shopping_cart, 'title': 'New order #1234', 'time': '2 min ago', 'color': Colors.green},
      {'icon': Icons.people, 'title': 'New follower', 'time': '5 min ago', 'color': Colors.purple},
      {'icon': Icons.star, 'title': 'Product review received', 'time': '1 hour ago', 'color': Colors.orange},
      {'icon': Icons.inventory_2, 'title': 'Low stock alert', 'time': '2 hours ago', 'color': Colors.red},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 241, 238, 246),
              Color.fromARGB(255, 225, 230, 244),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: activities.map((activity) {
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activity['color'] as Color? ?? Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(activity['title'] as String),
              subtitle: Text(activity['time'] as String),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            );
          }).toList(),
        ),
      ),
    );

  }

  Widget _buildInventoryStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(ShopOrderWithProductModel orderAndProducts) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 241, 238, 246),
              const Color.fromARGB(255, 225, 230, 244),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${orderAndProducts.id.substring(0, 14)}...',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(orderAndProducts.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      orderAndProducts.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(orderAndProducts.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), 
              // Product Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product: ${orderAndProducts.productName}'),
                        Text('Quantity: ${orderAndProducts.quantity}'),
                        Text('Total: Ksh ${orderAndProducts.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Date
              Text(
                'Ordered: ${DateFormat('MMM dd, yyyy - HH:mm').format(orderAndProducts.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Confirm Button (Elevated)
                  ElevatedButton.icon(
                    onPressed: orderAndProducts.status.toLowerCase() == 'pending'
                        ? () => _updateOrderStatus(orderAndProducts, 'confirmed')
                        : null,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderAndProducts.status.toLowerCase() == 'pending'
                          ? Colors.green
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Cancel Button (Outlined)
                  OutlinedButton.icon(
                    onPressed: orderAndProducts.status.toLowerCase() == 'pending'
                        ? () => _updateOrderStatus(orderAndProducts, 'cancelled')
                        : null,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: orderAndProducts.status.toLowerCase() == 'pending'
                          ? const Color.fromARGB(255, 239, 112, 103)
                          : Colors.grey.shade400,
                      side: BorderSide(
                        color: orderAndProducts.status.toLowerCase() == 'pending'
                            ? const Color.fromARGB(255, 239, 112, 103)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for status colors
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateOrderStatus(ShopOrderWithProductModel orderAndProducts, String newStatus) async {
    try {
      print('Updating order ${orderAndProducts.id} to status: $newStatus');
      
      await _orderService.updateOrderStatus(orderAndProducts.id, newStatus);
      print('Order status updated successfully to: $newStatus');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${newStatus.toLowerCase()} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload orders to reflect the change
        loadOrders();
      }
      
    } catch (e) {
      print('Error updating order status: $e');
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(KioskProvider kioskProvider) {
    final products = kioskProvider.products.where((p) => p.category != 'Service').toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductItem(products[index], kioskProvider);
      },
    );
  }

  Widget _buildServicesList(KioskProvider kioskProvider) {
    final services = kioskProvider.products.where((p) => p.category == 'Service').toList();
    
    return services.isEmpty
        ? _buildEmptyState('No Services', 'Add your first service to start offering')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceItem(services[index], kioskProvider);
            },
          );
  }

  Widget _buildDraftsList(KioskProvider kioskProvider) {
    final drafts = kioskProvider.products.where((p) => p.status == ProductStatus.draft).toList();
    
    return drafts.isEmpty
        ? _buildEmptyState('No Drafts', 'Create draft products or services')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              return _buildDraftItem(drafts[index], kioskProvider);
            },
          );
  }

  Widget _buildProductItem(Product product, KioskProvider kioskProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(product.name),
        subtitle: Text('\$${product.price.toStringAsFixed(2)} • ${product.stock} in stock'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) => _handleProductAction(value, product, kioskProvider),
        ),
      ),
    );
  }

  Widget _buildServiceItem(Product service, KioskProvider kioskProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.miscellaneous_services, color: Color(0xFF2196F3)),
        ),
        title: Text(service.name),
        subtitle: Text('\$${service.price.toStringAsFixed(2)} • Service'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) => _handleProductAction(value, service, kioskProvider),
        ),
      ),
    );
  }

  Widget _buildDraftItem(Product draft, KioskProvider kioskProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit, color: Colors.orange),
        ),
        title: Text(draft.name),
        subtitle: const Text('Draft • Not published'),
        trailing: IconButton(
          icon: const Icon(Icons.publish, color: Colors.green),
          onPressed: () => kioskProvider.updateProductStatus(draft.id, ProductStatus.active),
        ),
      ),
    );
  }

  Widget _buildShopProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF6C63FF),
              child: const Icon(Icons.store, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'My Awesome Shop',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fashion & Accessories',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStat('245', 'Followers'),
                _buildProfileStat('4.8', 'Rating'),
                _buildProfileStat('156', 'Orders'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    final settings = [
      {'icon': Icons.edit, 'title': 'Edit Shop Info', 'color': Colors.blue},
      {'icon': Icons.photo, 'title': 'Shop Images', 'color': Colors.purple},
      {'icon': Icons.delivery_dining, 'title': 'Delivery Settings', 'color': Colors.green},
      {'icon': Icons.payment, 'title': 'Payment Methods', 'color': Colors.orange},
      {'icon': Icons.notifications, 'title': 'Notification Settings', 'color': Colors.red},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: settings.map((setting) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: setting['color'] as Color? ?? Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(setting['icon'] as IconData, color: Colors.white, size: 20),
            ),
            title: Text(setting['title'] as String),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBusinessHours() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _BusinessHourRow(day: 'Monday - Friday', hours: '9:00 AM - 6:00 PM'),
            _BusinessHourRow(day: 'Saturday', hours: '10:00 AM - 4:00 PM'),
            _BusinessHourRow(day: 'Sunday', hours: 'Closed'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  void _updateStock(Product product, KioskProvider kioskProvider, int newStock) {
    if (newStock >= 0) {
      kioskProvider.updateProductStock(product.id, newStock);
    }
  }

  void _handleProductAction(String action, Product product, KioskProvider kioskProvider) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(context, product, kioskProvider);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(product, kioskProvider);
        break;
    }
  }

  void _showAddProductDialog(BuildContext context, KioskProvider kioskProvider) {
    // Implementation from previous code
  }

  void _showAddServiceDialog(BuildContext context, KioskProvider kioskProvider) {
    // Implementation for adding services
  }

  void _showEditProductDialog(BuildContext context, Product product, KioskProvider kioskProvider) {
    // Implementation from previous code
  }

  void _showDeleteConfirmationDialog(Product product, KioskProvider kioskProvider) {
    // Implementation from previous code
  }
}

extension on bool {
  String? get imageUrl => 'https://picsum.photos/400/600?random=1';
}

extension ShopOrderModelCustomerName on ShopOrderWithProductModel {
  /// Provides a safe getter for customer name using common possible field names.
  /// Uses `dynamic` access with a try/catch so this file compiles even if the
  /// underlying model uses a different field name; it will attempt several
  /// common alternatives and fall back to 'Unknown'.
  String get customerName {
    try {
      final dyn = this as dynamic;
      final value = dyn.customerName ?? dyn.customer ?? dyn.buyer ?? dyn.clientName ?? dyn.name;
      return value?.toString() ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }
}

class _BusinessHourRow extends StatelessWidget {
  final String day;
  final String hours;

  const _BusinessHourRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(hours, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// Keep the existing KioskProvider, Product, and ProductStatus classes from previous code
// They will work with the new UI