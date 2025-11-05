import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:versity_soko/services/product_service.dart';
import '../../models/shop_order_model.dart';
import '../../services/shop_order_service.dart';
import '../../models/product_model.dart';
import '../create/shop_redirector.dart';
import '../../models/shop_model.dart';
import 'dart:io';
import '../../services/showcase_service.dart';
import '../../models/showcase_model.dart';
import '../../models/ativity_model.dart';
import '../../services/shop_profile_service.dart';
import 'package:flutter/foundation.dart';
import '../../services/shop_profile_service.dart';


class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool userShowcase = true;
  late final bool hasUserPosted = true;
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
  File? _selectedImage;
  List<ShowcaseModel>? _showcase;
  final List<Activity> _activities = [
    Activity(
      icon: Icons.shopping_cart,
      title: 'Welcome to your shop!',
      time: DateTime.now(),
      color: Colors.blueAccent,
    ),
  ];



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadOrdersWithProduct();
    _loadProducts();
    fetchCurrentShopDetails();
    fetchShowcase();
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

  Future<void> fetchShowcase() async {
    try {
      final showcaseService = ShowcaseService();
      final hasShowcase = await showcaseService.hasShowcases();

      if (hasShowcase) {
        final showcases = await showcaseService.fetchShowcases();

        setState(() {
          _showcase = showcases;
        });

        print('✅ Fetched ${showcases.length} showcases');
      } else {
        print('ℹ️ No showcases found in the table');
        setState(() {
          _showcase = [];
        });
      }
    } catch (e) {
      print('🚨 Error fetching showcases: $e');
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
    String? imageUrl,
  ) async {
    try {
      // Create the updated product first
      final updatedProduct = product.copyWith(
        name: name,
        price: price,
        description: description,
        imageUrl: imageUrl,
      );
      print('updated product: $updatedProduct');

      await _productService.updateProductInList(updatedProduct);

      // Update the local state
      setState(() {
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index] = updatedProduct;
        }
      });

      // ✅ Add activity after successful update
      _addActivity(
        Activity(
          icon: Icons.edit,
          title: 'Updated product: $name',
          time: DateTime.now(),
          color: Colors.orangeAccent,
        ),
      );

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

      _addActivity(
        Activity(
          icon: Icons.delete,
          title: 'Deleted product: ${product.name}',
          time: DateTime.now(),
          color: Colors.redAccent,
        ),
      );

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

  void _addActivity(Activity newActivity) {
    setState(() {
      _activities.insert(0, newActivity); // Add to the top (most recent first)
      if (_activities.length > 7) {
        _activities.removeLast(); // Keep only latest 7
      }
    });
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
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 241, 238, 246),
                  Color.fromARGB(255, 225, 230, 244),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              color: Colors.transparent, // Keep gradient visible
              elevation: 0, // Use container shadow instead
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF9C27B0), // Purple accent
                  child: Icon(Icons.photo_library_rounded, color: Colors.white),
                ),
                title: const Text(
                  "Your Showcases",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                subtitle: Text(
                  _showcase?.isNotEmpty == true
                      ? "You have ${_showcase!.length} active showcase(s)"
                      : "No showcases yet — upload one to engage buyers.",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ),
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
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _shopDetails != null
                      ?  NetworkImage(_shopDetails!.imageUrl!)
                      : null,
                  child: _shopDetails == null
                      ? const Icon(Icons.image, size: 30, color: Colors.purple)
                      : null,
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
          _buildShowCaseStatus(_showcase ?? []),
          
          const Spacer(),
        ],
      )
    );
  }

  Widget _buildShowCaseStatus(List<ShowcaseModel> showcases) {
    if (showcases.isNotEmpty) {
      final latestShowcase = showcases.first;

      return GestureDetector(
        onTap: () {
          _showShowcaseDialog(latestShowcase);
        },
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF2196F3), // Blue
                Color(0xFF9C27B0), // Purple
                 // Green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(latestShowcase.mediaUrl),
            backgroundColor: Colors.grey[200],
          ),
        ),
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

  void _showShowcaseDialog(ShowcaseModel showcase) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 5), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });

        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  showcase.mediaUrl,
                  fit: BoxFit.cover,
                  height: 600,
                  width: double.infinity,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Text(
                  showcase.caption ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  // Navigator.pop(context);
                  _pickImageFromGallery(context);
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
              // ListTile(
              //   leading: const Icon(Icons.text_fields, color: Colors.blue),
              //   title: const Text('Write a Post'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _showTextInput();
              //   },
              // ),
              // const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(imageFile: File(image.path)),
        ),
      );
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
    if (_shopDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildShopProfileCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Business Hours'),
          const SizedBox(height: 16),
          _buildBusinessHours(_shopDetails!.businessHours),
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
    if (_activities.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No recent activity yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

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
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activities.length,
          itemBuilder: (context, index) {
            final activity = _activities[index];

            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activity.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(activity.icon, color: Colors.white, size: 20),
              ),
              title: Text(activity.title),
              subtitle: Text(
                _formatTimeAgo(activity.time),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
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
      await _orderService.updateOrderStatus(orderAndProducts.id, newStatus);

      // Log activity dynamically
      _addActivity(Activity(
        icon: Icons.shopping_cart,
        title: 'New Order ${orderAndProducts.productName} ${newStatus.toLowerCase()}',
        time: DateTime.now(),
        color: newStatus.toLowerCase() == 'confirmed'
            ? Colors.green
            : newStatus.toLowerCase() == 'cancelled'
                ? Colors.red
                : Colors.blue,
      ));

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
      // Log error activity
      _addActivity(Activity(
        icon: Icons.error_outline,
        title: 'Failed to update order ${orderAndProducts.productName}',
        time: DateTime.now(),
        color: Colors.orange,
      ));

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
                  '${product.imageUrl}',
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
    final deliveryValue = _shopDetails?.delivery?.toString() ?? 'N/A';

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
              backgroundImage: (_shopDetails?.imageUrl != null && _shopDetails!.imageUrl!.isNotEmpty)
                  ? NetworkImage(_shopDetails!.imageUrl!)
                  : null,
              child: (_shopDetails?.imageUrl == null || _shopDetails!.imageUrl!.isEmpty)
                  ? const Icon(Icons.store, size: 40, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _shopDetails?.name ?? 'Shop Name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _shopDetails?.category ?? 'No category',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStat('245', 'Followers'),
                _buildProfileStat(deliveryValue, 'Delivery'),
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

  Widget _buildBusinessHours(Map<String, dynamic>? businessHours) {
    if (businessHours == null) {
      return const Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Business hours not set',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final openDays = businessHours['open_days'] as Map<String, dynamic>? ?? {};
    final openTime = businessHours['open_time'] ?? 'N/A';
    final closeTime = businessHours['close_time'] ?? 'N/A';

    final daysOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: daysOrder.map((day) {
            final isOpen = openDays[day] ?? false;
            return _BusinessHourRow(
              day: day,
              isOpen: isOpen,
              openTime: openTime,
              closeTime: closeTime,
            );
          }).toList(),
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

                  _addActivity(
                    Activity(
                      color: Colors.indigoAccent, 
                      icon: Icons.add_box, 
                      title: 'New Product Added: $name', 
                      time: DateTime.now()
                    )
                  );

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

    File? _selectedImage;
    String? _updatedImageUrl;
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // local helper to pick an image and update dialog state
          Future<void> _pickImage() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 75,
              );

              if (pickedFile != null) {
                // debug
                print('📸 picked: ${pickedFile.path}');
                setDialogState(() {
                  _selectedImage = File(pickedFile.path);
                  // reset uploaded url if user changes image again
                  _updatedImageUrl = null;
                });
              }
            } catch (e) {
              print('Error picking image: $e');
            }
          }

          // local helper to upload image and update dialog state
          Future<String?> _uploadProductImage(File imageFile) async {
            try {
              setDialogState(() => _isUploading = true);

              // debug
              print('⬆️ uploading file: ${imageFile.path}');

              final String? uploadedUrl = await _productService.uploadProductImage(imageFile);

              if (uploadedUrl != null) {
                print('✅ uploaded url: $uploadedUrl');
                setDialogState(() {
                  _updatedImageUrl = uploadedUrl;
                  _isUploading = false;
                });

                // optional snack
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image uploaded successfully'), backgroundColor: Colors.green),
                );
                return uploadedUrl;
              } else {
                setDialogState(() => _isUploading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload returned null'), backgroundColor: Colors.red),
                );
              }
            } catch (e) {
              setDialogState(() => _isUploading = false);
              print('Upload error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload image: $e'), backgroundColor: Colors.red),
              );
            }
          }

          return AlertDialog(
            title: const Text('Edit Product'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    height: 140,
                                    width: 140,
                                    fit: BoxFit.cover,
                                  )
                                : (_updatedImageUrl != null
                                    ? Image.network(
                                        _updatedImageUrl!,
                                        height: 140,
                                        width: 140,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.blue)
                                )
                          ),

                          // overlay camera icon
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
                          ),

                          // uploading indicator overlay
                          if (_isUploading)
                            Positioned.fill(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedImage != null ? 'New image selected' : 'Tap to change image',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name *', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter product name' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price *', prefixText: 'Ksh ', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter price';
                        if (double.tryParse(value) == null) return 'Please enter a valid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
             
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  // If user selected image but didn't hit "Upload Image", upload now.
                  if (_selectedImage != null && _updatedImageUrl == null) {
                    final uploadedUrl = await _uploadProductImage(_selectedImage!);
                    
                    _updatedImageUrl = uploadedUrl;
                    
                  }

                  // Use updated image url if available, otherwise leave existing product.imageUrl
                  final imageUrlToUse = _updatedImageUrl ?? product.imageUrl;

                  await _performEditProduct(
                    product,
                    _nameController.text,
                    double.parse(_priceController.text),
                    _descriptionController.text.isEmpty ? null : _descriptionController.text,
                    imageUrlToUse,
                  );

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }



  Future<void> _uploadProductImage(File imageFile) async {
    bool _isUploading = false;
    setState(() => _isUploading = true);

    try {
      // You can generate a filename or keep the original
      final filename = imageFile.path.split('/').last;
      print('🖼️ Uploading product image: $filename');

      final uploadedProduct = await _productService.uploadProductImage(
        imageFile,
        // You can add more parameters here if needed, e.g., productId
      );

      if (uploadedProduct != null) {
        // print('✅ Product image uploaded: ${uploadedProduct.id}');
        if (mounted) Navigator.pop(context);
      } else {
        print('⚠️ Product image upload failed.');
      }

    } catch (e) {
      print('🚨 Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
  final bool isOpen;
  final String? openTime;
  final String? closeTime;

  const _BusinessHourRow({
    required this.day,
    required this.isOpen,
    this.openTime,
    this.closeTime,
  });

  @override
  Widget build(BuildContext context) {
    final hoursText = isOpen
        ? '$openTime - $closeTime'
        : 'Closed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            hoursText,
            style: TextStyle(
              color: isOpen ? Colors.grey[700] : Colors.redAccent,
              fontWeight: isOpen ? FontWeight.normal : FontWeight.w600,
            ),
          ),
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
  final shopService = ShopProfileService();
  final shopIdClass = ShopHelper();
  ShopModel? shopDetails; // holds fetched shop details
  // Fetch shop profile

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
      print('⬆️ Uploading image: ${file.path}');
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

  Future<String?> _shopId() async {
    final shopId = await shopIdClass.getCurrentShopId();
    return shopId;
  }

  Future<void> fetchCurrentShopDetails() async {
    try {
      final shopId = await _shopId();

      if (shopId == null || shopId.isEmpty) {
        print('⚠️ No shop ID found for current user');
        shopDetails = null;
        setState(() {});
        return;
      }

      final shopData = await shopService.fetchShopProfile(shopId);

      if (shopData != null) {
        setState(() {
          shopDetails = ShopModel.fromJson(shopData);
        });
        print('✅ Loaded shop details: ${shopDetails!.name}');
      } else {
        print('⚠️ No shop found for current user');
        setState(() => shopDetails = null);
      }
    } catch (e, stackTrace) {
      print('🚨 Error fetching shop details: $e');
      print(stackTrace);
      setState(() => shopDetails = null);
    }
  }

  Future<String> _uploadToSupabaseStorage(XFile file, String shopId) async {
    // Convert XFile to File
    final File imageFile = File(file.path);

    // Use the improved uploadProfileImage function
    final publicUrl = await shopService.uploadProfileImage(
    imageFile: imageFile,
    shopId: shopId,
    );

    if (publicUrl == null) {
    throw Exception('❌ Failed to upload image to Supabase.');
    }

    print('✅ Uploaded image URL: $publicUrl');
    return publicUrl;
  }

  Future<void> _saveShopProfile() async {
    try {
      // Get current shop ID 
      final shopId = await shopIdClass.getCurrentShopId();

      if (shopId == null) {
        throw Exception('Shop ID not found');
      }

      // Update profile using service
      final success = await shopService.updateShopProfile(
        shopId: shopId,
        name: widget.nameController.text.trim(),
        category: widget.categoryController.text.trim(), // Using category as description
        profileImageUrl: widget.imageUrlController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shop profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      appBar: AppBar(
        title: const Text(
          'Shop Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ---- Shop Image Section ----
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 241, 238, 246),
                    Color.fromARGB(255, 225, 230, 244),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Shop Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 103, 103, 103),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: widget.imageUrlController.text.isNotEmpty
                            ? NetworkImage(widget.imageUrlController.text)
                            : null,
                        child: widget.imageUrlController.text.isEmpty
                            ? const Icon(Icons.store, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _isUploading ? null : _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(1, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap the camera to upload your shop logo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---- Shop Details Section ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 241, 238, 246),
                    Color.fromARGB(255, 225, 230, 244),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: widget.nameController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 103, 103, 103)),
                    decoration: InputDecoration(
                      labelText: 'Shop Name',
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 103, 103, 103)),
                      prefixIcon: const Icon(Icons.storefront,
                          color: Color(0xFF667EEA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.green),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 210, 210, 210),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: widget.categoryController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 103, 103, 103)),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 103, 103, 103)),
                      prefixIcon: const Icon(Icons.category_outlined,
                          color: Color(0xFF667EEA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.green),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 210, 210, 210),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: widget.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 103, 103, 103)),
                    decoration: InputDecoration(
                      labelText: 'Business Email',
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 103, 103, 103)),
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: Color(0xFF667EEA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.green),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 210, 210, 210),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---- Save Button ----
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF764BA2),
                      Color(0xFF667EEA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _saveShopProfile();
                   
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Save Shop Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
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
    appBar: AppBar( 
      title: const Text( 
        'Shop Profile', 
        style: TextStyle(
          fontWeight: FontWeight.bold), 
        ), 
      centerTitle: true, 
      backgroundColor: Colors.white, 
      foregroundColor: Colors.black, 
      elevation: 0, 
    ), 
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
          const SizedBox(height: 30), // space for FAB
          // ---- Operating Hours Card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromARGB(255, 241, 238, 246),
                  Color.fromARGB(255, 225, 230, 244),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
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
                      const Icon(Icons.info_outline,
                          size: 20, color: Color(0xFF4CAF50)),
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

          const SizedBox(height: 24),

          // ---- Open Days Card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromARGB(255, 241, 238, 246),
                  Color.fromARGB(255, 225, 230, 244),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
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
                ..._daysOpen.entries
                    .map((entry) => _buildDayToggle(entry.key, entry.value))
                    .toList(),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ---- Save Button ----
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                    // Handle save action
                    // Keep original _daysOpen map since it's already in the correct format
                    try {
                    final shopService = ShopProfileService();
                    final shopHelper = ShopHelper();
                    
                    // Get current shop ID
                    final shopId = await shopHelper.getCurrentShopId();
                    
                    if (shopId != null) {
                      await shopService.updateShopBusinessHrs(
                      shopId: shopId,
                      openingTime: TimeOfDay(hour: _openingTime.hour, minute: _openingTime.minute),
                      closingTime: TimeOfDay(hour: _closingTime.hour, minute: _closingTime.minute),
                      openDays: _daysOpen,
                      );
                      
                      if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('Business hours updated successfully'),
                        backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                      }
                    }
                    } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                      content: Text('Failed to update business hours: $e'),
                      backgroundColor: Colors.red,
                      ),
                    );
                    }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Business hours updated successfully'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Save Business Hours',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
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

  Future<void> _savePaymentMethod() async {
    if (_validateForm()) {
      // Save the payment method
      try {
        final shopHelper = ShopHelper();
        final shopService = ShopProfileService();
        
        // Get current shop ID
        final shopId = await shopHelper.getCurrentShopId();
        
        if (shopId == null) {
          throw Exception('Shop ID not found');
        }

        // Create payment details map based on selected method
        Map<String, dynamic> paymentDetails = {
          'method': _selectedMethod,
        };

        // Add specific details based on payment method
        switch (_selectedMethod) {
          case 'mpesa_send':
            paymentDetails['mobile_number'] = _mobileNumberController.text.trim();
            break;
          case 'paybill':
            paymentDetails['paybill_number'] = _paybillNumberController.text.trim();
            paymentDetails['account_number'] = _accountNumberController.text.trim();
            break;
          case 'pochi':
            paymentDetails['pochi_number'] = _pochiNumberController.text.trim();
            break;
        }

        // Update payment method using service
        final success = await shopService.updatePaymentMethod(
          shopId: shopId,
          paymentDetails: paymentDetails,
        );

        if (success) {
          if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
          }
        } else {
          throw Exception('Failed to update payment method');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('Error saving payment method: $e'),
        backgroundColor: Colors.red,
          ),
        );
      }
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
      appBar: AppBar( 
      title: const Text( 
        'Shop Profile', 
        style: TextStyle(
          fontWeight: FontWeight.bold), 
        ), 
      centerTitle: true, 
      backgroundColor: Colors.white, 
      foregroundColor: Colors.black, 
      elevation: 0, 
    ), 
    backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60), // Space for back button
              
              // Header with Gradient
              
              
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

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const ImagePreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ShowcaseService _showcaseService = ShowcaseService();

  bool _isUploading = false;

  Future<void> _uploadShowcase() async {
    setState(() => _isUploading = true);

    try {
      final caption = _captionController.text.trim();
      final priceText = _priceController.text.trim();

      // Optional price formatting
      final price = priceText.isNotEmpty ? 'KSh $priceText' : null;
      final fullCaption = price != null ? '$caption • $price' : caption;

      print('🖼️ Uploading image with caption: $fullCaption');

      final showcase = await _showcaseService.uploadShowcase(
        imageFile: widget.imageFile,
        caption: fullCaption,
        expiresAt: DateTime.now().add(const Duration(days: 3)), // Example: 3 days expiry
      );

      if (showcase != null) {
        print('✅ Showcase uploaded: ${showcase.id}');
        if (mounted) Navigator.pop(context);
      } else {
        print('⚠️ Showcase upload failed.');
      }
    } catch (e) {
      print('🚨 Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Preview & Caption'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[400]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Image Preview Section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Image.file(
                  widget.imageFile,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Input and Button Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Caption Input
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      labelText: 'Caption or Description',
                      prefixIcon: const Icon(Icons.text_fields, color: Colors.purple),
                      filled: true,
                      fillColor: Colors.white,
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
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    cursorColor: Colors.green, // active typing color
                    maxLines: 2
                  ),
                  const SizedBox(height: 12),

                  // Price Input
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (optional)',
                      prefixIcon: const Icon(Icons.monetization_on_sharp, color: Colors.purple),
                      filled: true,
                      fillColor: Colors.white,
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
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    cursorColor: Colors.green, // active typing color
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadShowcase,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        _isUploading ? 'Uploading...' : 'Post',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.purple[400],
                        elevation: 3,
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
}
