import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:versity_soko/services/product_service.dart';
import '../../models/shop_order_model.dart';
import '../../services/shop_order_service.dart';
import '../../models/product_model.dart';
import '../create/shop_redirector.dart';
import '../../models/shop_model.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool userShowcase = false;
  late final bool hasUserPosted = userShowcase;
  late final String? showcaseImage = userShowcase ? 'https://picsum.photos/400/600?random=15' : null;
  List<Product> products = [];
  List<ShopOrderWithProductModel> orderAndProducts = [];
  final ShopOrderService _orderService = ShopOrderService();
  final ProductService _productService = ProductService();
  final ShopHelper _redirector = ShopHelper();
  bool _isLoading = false;
  String? _currentShopId;
  ShopModel? _shopDetails;
  ShopModel? get shopDetails => _shopDetails;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadOrdersWithProduct();
    _loadProducts();
    fetchCurrentShopDetails();
  }

  void loadOrdersWithProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedOrdersWithProducts = await _orderService.fetchShopOrdersWithProducts();
      
      setState(() {
        orderAndProducts = fetchedOrdersWithProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current shop ID
      _currentShopId = await _redirector.getCurrentShopId();
      
      if (_currentShopId == null || _currentShopId!.isEmpty) {
        print('No shop ID available to fetch products');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      print('Fetching products for shop: $_currentShopId');
      final fetchedProducts = await _productService.fetchProducts(_currentShopId!);
      
      if (mounted) {
        setState(() {
          products = fetchedProducts;
          _isLoading = false;
        });
        
        print('Successfully loaded ${fetchedProducts.length} products');
      }
    } catch (e) {
      print('Failed to load products: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> fetchCurrentShopDetails() async {
    try {
      final shopData = await _redirector.getShopDetails();

      if (shopData != null) {
        _shopDetails = ShopModel.fromJson(shopData);
        print('✅ Fetched shop details: $_shopDetails');
      } else {
        print('⚠️ No shop found for current user');
        _shopDetails = null;
      }
    } catch (e) {
      print('🚨 Error fetching shop details: $e');
      _shopDetails = null;
    }
  }


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  Future<void> _performEditProduct(
    Product product,
    String name,
    double price,
    String? description,
  ) async {
    try {
      // Create the updated product first
      final updatedProduct = product.copyWith(
        name: name,
        price: price,
        description: description,
      );

      await _productService.updateProductInList(updatedProduct);

      // Update the local state
      setState(() {
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index] = updatedProduct;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _performDeleteProduct(Product product) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(width: 16),
              Text('Deleting "${product.name}"...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 5),
        ),
      );

      // Delete from database
      await _productService.removeProduct(product.id);

      // Update local state
      if (mounted) {
        setState(() {
          products.removeWhere((p) => p.id == product.id);
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${product.name}" deleted successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      print('Product "${product.name}" deleted successfully');

    } catch (e) {
      // Hide loading indicator and show error
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      print('Error deleting product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        backgroundColor: Colors.transparent,
        elevation: 0,
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
    );
  }

  Widget _buildOverviewTab() {
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
                  color: const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Monthly Revenue',
                  value: '\$2,845',
                  change: '+8%',
                  icon: Icons.attach_money,
                  color: const Color(0xFF2196F3),
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
                  color: const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Monthly Orders',
                  value: '156',
                  change: '+12%',
                  icon: Icons.shopping_cart,
                  color: const Color(0xFF4CAF50),
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
  }

  Widget _buildOrderTab() {
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showShowCaseOptions,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: const NetworkImage('https://picsum.photos/400/600?random=15'),
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
          const SizedBox(width: 40),

          // Status/Avatar or "No post yet" text
          _buildShowCaseStatus(hasUserPosted, showcaseImageUrl: showcaseImage),
          
          const Spacer(),
        ],
      )
    );
  }

  Widget _buildShowCaseStatus(bool hasUserPosted, {String? showcaseImageUrl}) {
    if (hasUserPosted && showcaseImageUrl != null) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF833AB4),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(showcaseImageUrl),
          backgroundColor: Colors.grey,
        )
      );
    } else {
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

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Handle the picked image
        print('Image picked: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        // Handle the taken photo
        print('Photo taken: ${photo.path}');
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  void _showTextInput() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Post'),
        content: TextFormField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What would you like to share?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle post submission
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _buildProductsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green.shade400,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }


  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildShopProfileCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Business Hours'),
          const SizedBox(height: 16),
          _buildBusinessHours(),
          const SizedBox(height: 24),
          _buildSectionHeader('Shop Settings'),
          const SizedBox(height: 16),
          _buildSettingsList(),
          const SizedBox(height: 24),
        ],
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  color: activity['color'] as Color,
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
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 241, 238, 246),
              Color.fromARGB(255, 225, 230, 244),
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
              Text(
                'Ordered: ${DateFormat('MMM dd, yyyy - HH:mm').format(orderAndProducts.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${newStatus.toLowerCase()} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        loadOrdersWithProduct();
      }
      
    } catch (e) {
      print('Error updating order status: $e');
      
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient( 
              colors: [Colors.purple[50]!, Colors.blue[50]!], 
              begin: Alignment.topLeft, 
              end: Alignment.bottomRight, 
            ),
          ),
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

  Widget _buildProductsList() {
    final productItems = products.toList();
    
    return productItems.isEmpty
        ? _buildEmptyState('No Products', 'Add your first product to start selling')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productItems.length,
            itemBuilder: (context, index) {
              return _buildProductItem(productItems[index]);
            },
          );
  }

  Widget _buildServicesList() {
    final services = products.toList();
    
    return services.isEmpty
        ? _buildEmptyState('No Services', 'Add your first service to start offering')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceItem(services[index]);
            },
          );
  }

  // Widget _buildDraftsList() {
  //   final drafts = products.where((p) => p.status == ProductStatus.draft).toList();
    
  //   return drafts.isEmpty
  //       ? _buildEmptyState('No Drafts', 'Create draft products or services')
  //       : ListView.builder(
  //           padding: const EdgeInsets.all(16),
  //           itemCount: drafts.length,
  //           itemBuilder: (context, index) {
  //             return _buildDraftItem(drafts[index]);
  //           },
  //         );
  // }


  Widget _buildProductItem(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent, // let the gradient show through
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://picsum.photos/100/100?random=${product.id.hashCode % 100}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              // 📄 Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Product Description
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 6),

                    // Price & Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ksh ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Added ${_formatDate(product.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ⋮ Popup Menu
              PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (value) => _handleProductAction(value, product),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildServiceItem(Product service) {
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
        subtitle: Text('Ksh ${service.price.toStringAsFixed(2)} • Service'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) => _handleProductAction(value, service),
        ),
      ),
    );
  }

  Widget _buildDraftItem(Product draft) {
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
          onPressed: () => {}/*_publishDraft(draft),*/
        ),
      ),
    );
  }

  // Future<void> _publishDraft(Product draft) async {
  //   try {
  //     final publishedProduct = draft.copyWith(status: ProductStatus.active);
  //     await _productService.updateProductInList(publishedProduct);
      
  //     setState(() {
  //       final index = products.indexWhere((p) => p.id == draft.id);
  //       if (index != -1) {
  //         products[index] = publishedProduct;
  //       }
  //     });
      
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Product published successfully'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to publish product: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

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
            Text(
              _shopDetails?.name ?? 'Shop Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _shopDetails?.category ?? 'No category',
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
                _buildProfileStat(_shopDetails!.delivery.toString(), 'Delivery'),
                _buildProfileStat("${orderAndProducts.length}", 'Orders'),
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
      {'icon': Icons.edit, 'title': 'Edit Shop Profile', 'color': Colors.blue},
      {'icon': Icons.timelapse, 'title': 'Change Business Hrs', 'color': Colors.purple},
      {'icon': Icons.delivery_dining, 'title': 'Delivery Settings', 'color': Colors.green},
      {'icon': Icons.payment, 'title': 'Payment Methods', 'color': Colors.orange},
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
                color: setting['color'] as Color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                setting['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(setting['title'] as String),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Trigger navigation based on the setting title
              switch (setting['title']) {
                case 'Edit Shop Profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ShopProfileEditor(
                      nameController: _nameController,
                      categoryController: _categoryController,
                      emailController: _emailController,
                      imageUrlController: _imageUrlController,
                    )),
                  );
                  break;

                case 'Change Business Hrs':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BusinessHoursEditor()),
                  );
                  break;

                case 'Payment Methods':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentMethodsSelector()),
                  );
                  break;

                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This setting is not yet available.')),
                  );
              }
            },
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

  void _handleProductAction(String action, Product product) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(context, product);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(product);
        break;
    }
  }

  void _showAddProductDialog(BuildContext parentContext) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Add New Product',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final priceText = priceController.text.trim();

                // ✅ Validation
                if (name.isEmpty || priceText.isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Name and price are required')),
                  );
                  return;
                }

                final price = double.tryParse(priceText);
                if (price == null || price <= 0) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Enter a valid price')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(); // Close dialog first

                try {
                  setState(() => _isLoading = true);
                  

                  // ✅ Use your service to add product
                  await _productService.addProduct(
                    shopId: _currentShopId!,
                    name: name,
                    price: price,
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  );

                  await _loadProducts(); // refresh the list

                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Product added successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Failed to add product: $e')),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditProductDialog(BuildContext context, Product product) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product.name);
    final _priceController = TextEditingController(text: product.price.toString());
    final _descriptionController = TextEditingController(text: product.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: 'Ksh ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Stock (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _performEditProduct(
                  product,
                  _nameController.text,
                  double.parse(_priceController.text),
                  _descriptionController.text.isEmpty ? null : _descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${product.name}"?'),
            const SizedBox(height: 8),
            Text(
              'Price: Ksh ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Description: ${product.description!}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDeleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

class ShopProfileEditor extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController categoryController;
  final TextEditingController emailController;
  final TextEditingController imageUrlController;
  final VoidCallback? onImageChanged;

  const ShopProfileEditor({
    super.key,
    required this.nameController,
    required this.categoryController,
    required this.emailController,
    required this.imageUrlController,
    this.onImageChanged,
  });

  @override
  State<ShopProfileEditor> createState() => _ShopProfileEditorState();
}

class _ShopProfileEditorState extends State<ShopProfileEditor> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _categoryFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add focus listeners to trigger UI updates
    _nameFocusNode.addListener(() => setState(() {}));
    _categoryFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _categoryFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo != null) {
        await _uploadImage(photo);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _uploadImage(XFile file) async {
    if (!mounted) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Generate unique file name
      final String fileName = 'shop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to Supabase storage
      final String imageUrl = await _uploadToSupabaseStorage(file, fileName);
      
      if (mounted) {
        setState(() {
          widget.imageUrlController.text = imageUrl;
        });
        
        // Notify parent about image change
        widget.onImageChanged?.call();
        
        _showSuccessSnackBar('Image uploaded successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> _uploadToSupabaseStorage(XFile file, String fileName) async {
    // TODO: Implement your Supabase storage upload logic
    // Example:
    // final bytes = await file.readAsBytes();
    // final response = await supabase.storage
    //   .from('shop-images')
    //   .upload(fileName, bytes);
    // 
    // return supabase.storage
    //   .from('shop-images')
    //   .getPublicUrl(response);
    
    // For now, return a placeholder or the file path
    return file.path;
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.3))],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      color: Colors.blue.shade100,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      color: Colors.green.shade100,
                      onTap: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.blue.shade800),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  InputDecoration _buildGradientInputDecoration({
    required String labelText,
    required String hintText,
    required bool hasFocus,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: hasFocus ? const Color(0xFF4CAF50) : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: hasFocus
          ? Container(
              margin: const EdgeInsets.only(left: 12, right: 8),
              width: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667EEA),
        elevation: 4,
        child: const Icon(Icons.arrow_back, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60), // Space for back button
              
              // Header with Gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.store, size: 40, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'Shop Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black.withOpacity(0.2))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your shop appearance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Image Upload Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Image Preview with Gradient Border
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                image: widget.imageUrlController.text.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(widget.imageUrlController.text),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _isUploading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                                      ),
                                    )
                                  : widget.imageUrlController.text.isEmpty
                                      ? const Icon(Icons.add_photo_alternate, size: 40, color: Color(0xFF667EEA))
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isUploading ? null : _showImageSourceDialog,
                                icon: const Icon(Icons.upload, size: 20),
                                label: const Text('Upload Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667EEA),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.imageUrlController.text.isEmpty
                                    ? 'Add your shop logo or image'
                                    : 'Image ready for upload',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Form Fields Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: widget.nameController,
                      focusNode: _nameFocusNode,
                      decoration: _buildGradientInputDecoration(
                        labelText: 'Shop Name *',
                        hintText: 'Enter your shop name',
                        hasFocus: _nameFocusNode.hasFocus,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: widget.categoryController,
                      focusNode: _categoryFocusNode,
                      decoration: _buildGradientInputDecoration(
                        labelText: 'Category *',
                        hintText: 'e.g., Fashion, Electronics, Food',
                        hasFocus: _categoryFocusNode.hasFocus,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: widget.emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildGradientInputDecoration(
                        labelText: 'Business Email *',
                        hintText: 'your-shop@email.com',
                        hasFocus: _emailFocusNode.hasFocus,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Shop Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessHoursEditor extends StatefulWidget {
  const BusinessHoursEditor({super.key});

  @override
  State<BusinessHoursEditor> createState() => _BusinessHoursEditorState();
}

class _BusinessHoursEditorState extends State<BusinessHoursEditor> {
  TimeOfDay _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 18, minute: 0);
  final Map<String, bool> _daysOpen = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': false,
    'Sunday': false,
  };

  Future<void> _pickTime(bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openingTime : _closingTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667EEA),
              secondary: Color(0xFF764BA2),
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  Widget _buildTimePickerCard(String title, TimeOfDay time, bool isOpening) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667EEA).withOpacity(0.1),
              const Color(0xFF764BA2).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF667EEA).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pickTime(isOpening),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF667EEA).withOpacity(0.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOpening ? Icons.sunny : Icons.nightlight_round,
                    size: 18,
                    color: const Color(0xFF667EEA),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDayToggle(String day, bool isOpen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isOpen 
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOpen ? Icons.check_circle : Icons.circle_outlined,
            color: isOpen ? const Color(0xFF4CAF50) : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          day,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          isOpen ? 'Open' : 'Closed',
          style: TextStyle(
            color: isOpen ? const Color(0xFF4CAF50) : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Switch(
          value: isOpen,
          onChanged: (value) {
            setState(() {
              _daysOpen[day] = value;
            });
          },
          activeColor: const Color(0xFF4CAF50),
          activeTrackColor: const Color(0xFF4CAF50).withOpacity(0.3),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667EEA),
        elevation: 4,
        child: const Icon(Icons.arrow_back, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60), // Space for back button
              
              // Header with Gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.access_time, size: 40, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'Business Hours',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black.withOpacity(0.2))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set your shop operating hours',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Operating Hours Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.schedule,
                            size: 20,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Daily Operating Hours',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildTimePickerCard('Opening Time', _openingTime, true),
                        const SizedBox(width: 16),
                        _buildTimePickerCard('Closing Time', _closingTime, false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your shop will be open from ${_openingTime.format(context)} to ${_closingTime.format(context)} on selected days',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Days Selection Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF764BA2).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Color(0xFF764BA2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Open Days',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._daysOpen.entries.map((entry) => 
                      _buildDayToggle(entry.key, entry.value)
                    ).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Business hours updated successfully'),
                        backgroundColor: const Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Business Hours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodsSelector extends StatefulWidget {
  const PaymentMethodsSelector({super.key});

  @override
  State<PaymentMethodsSelector> createState() => _PaymentMethodsSelectorState();
}

class _PaymentMethodsSelectorState extends State<PaymentMethodsSelector> {
  String? _selectedMethod;
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _paybillNumberController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _pochiNumberController = TextEditingController();

  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _paybillFocusNode = FocusNode();
  final FocusNode _accountFocusNode = FocusNode();
  final FocusNode _pochiFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _mobileFocusNode.addListener(() => setState(() {}));
    _paybillFocusNode.addListener(() => setState(() {}));
    _accountFocusNode.addListener(() => setState(() {}));
    _pochiFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _paybillNumberController.dispose();
    _accountNumberController.dispose();
    _pochiNumberController.dispose();
    _mobileFocusNode.dispose();
    _paybillFocusNode.dispose();
    _accountFocusNode.dispose();
    _pochiFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _buildGradientInputDecoration({
    required String labelText,
    required String hintText,
    required bool hasFocus,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: hasFocus ? const Color(0xFF4CAF50) : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 60),
    );
  }

  Widget _buildPaymentMethodCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedMethod == value 
              ? const Color(0xFF4CAF50) 
              : Colors.grey.shade200,
          width: _selectedMethod == value ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        value: value,
        groupValue: _selectedMethod,
        onChanged: (value) => setState(() => _selectedMethod = value),
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildMpesaSendMoneyFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00A650).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A650).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_android, color: const Color(0xFF00A650), size: 18),
              const SizedBox(width: 8),
              Text(
                'M-Pesa Mobile Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mobileNumberController,
            focusNode: _mobileFocusNode,
            keyboardType: TextInputType.phone,
            decoration: _buildGradientInputDecoration(
              labelText: 'Mobile Number *',
              hintText: '07XX XXX XXX',
              hasFocus: _mobileFocusNode.hasFocus,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  '+254',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaybillFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: const Color(0xFF667EEA), size: 18),
              const SizedBox(width: 8),
              Text(
                'Paybill Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paybillNumberController,
            focusNode: _paybillFocusNode,
            keyboardType: TextInputType.number,
            decoration: _buildGradientInputDecoration(
              labelText: 'Paybill Number *',
              hintText: 'Enter paybill number',
              hasFocus: _paybillFocusNode.hasFocus,
              prefixIcon: Icon(Icons.numbers, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountNumberController,
            focusNode: _accountFocusNode,
            keyboardType: TextInputType.text,
            decoration: _buildGradientInputDecoration(
              labelText: 'Account Number *',
              hintText: 'Enter account number',
              hasFocus: _accountFocusNode.hasFocus,
              prefixIcon: Icon(Icons.person, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPochiFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF764BA2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF764BA2).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: const Color(0xFF764BA2), size: 18),
              const SizedBox(width: 8),
              Text(
                'Pochi la Biashara',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pochiNumberController,
            focusNode: _pochiFocusNode,
            keyboardType: TextInputType.phone,
            decoration: _buildGradientInputDecoration(
              labelText: 'Pochi Number *',
              hintText: 'Enter Pochi number',
              hasFocus: _pochiFocusNode.hasFocus,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  '+254',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payment method'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    if (_selectedMethod == 'mpesa_send' && _mobileNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your mobile number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    if (_selectedMethod == 'paybill' && 
        (_paybillNumberController.text.isEmpty || _accountNumberController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both paybill and account numbers'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    if (_selectedMethod == 'pochi' && _pochiNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your Pochi number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    return true;
  }

  void _savePaymentMethod() {
    if (_validateForm()) {
      // Save the payment method
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment method saved successfully'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667EEA),
        elevation: 4,
        child: const Icon(Icons.arrow_back, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60), // Space for back button
              
              // Header with Gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.payment, size: 40, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'Payment Methods',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black.withOpacity(0.2))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your preferred payment method',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Methods Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            size: 20,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethodCard(
                      'M-Pesa Send Money',
                      'mpesa_send',
                      Icons.phone_android,
                      const Color(0xFF00A650),
                    ),
                    _buildPaymentMethodCard(
                      'Pochi la Biashara',
                      'pochi',
                      Icons.account_balance_wallet,
                      const Color(0xFF764BA2),
                    ),
                    _buildPaymentMethodCard(
                      'Paybill',
                      'paybill',
                      Icons.receipt_long,
                      const Color(0xFF667EEA),
                    ),
                  ],
                ),
              ),
              
              // Conditional Input Fields
              if (_selectedMethod != null) ...[
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedMethod == 'mpesa_send'
                      ? _buildMpesaSendMoneyFields()
                      : _selectedMethod == 'paybill'
                          ? _buildPaybillFields()
                          : _selectedMethod == 'pochi'
                              ? _buildPochiFields()
                              : const SizedBox.shrink(),
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}