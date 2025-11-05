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
import '../create/kiosk_editor.dart';
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
    // Activity(
    //   icon: Icons.shopping_cart,
    //   title: 'Welcome to your shop!',
    //   time: DateTime.now(),
    //   color: Colors.blueAccent,
    // ),
  ];
  final _shopService = ShopProfileService();
  bool _hasDelivery = false;


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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final fetchedProducts = await _productService.fetchProducts(_currentShopId!);
      
      if (mounted) {
        setState(() {
          products = fetchedProducts;
          _isLoading = false;
        });
        
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadShopDetails() async {
    final data = await _shopService.getShopById(_currentShopId!);
    setState(() {
      _shopDetails = data;
      _hasDelivery = _shopDetails?.delivery ?? false; // load from DB
    });
  }

  Future<void> fetchCurrentShopDetails() async {
    try {
      final shopData = await _redirector.getShopDetails();

      if (shopData != null) {
        _shopDetails = ShopModel.fromJson(shopData);
      } else {
        _shopDetails = null;
      }
    } catch (e) {
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

      } else {
        setState(() {
          _showcase = [];
        });
      }
    } catch (e) {
      setState(() {
        _showcase = [];
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
  }
}


  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('Error Picking the Image: $e'),
        backgroundColor: Colors.red,
          ),
        );
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
          _buildSectionHeader('Paymnent Methods'),
          const SizedBox(height: 16),
          _buildPaymentMethods(),
          const SizedBox(height: 24),
          _buildSectionHeader('Shop Settings'),
          const SizedBox(height: 16),
          _buildSettingsList(),
          const SizedBox(height: 24),
          
        ],
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
        color: Colors.transparent,
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
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),

                    const SizedBox(height: 4),

                    // Product Description (wraps softly if long)
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),

                    const SizedBox(height: 6),

                    // Price & Date Row (wrap gracefully if too long)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
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

  Widget _buildProfileStat(dynamic value, String label) {
    String displayValue = value.toString();
    Color valueColor = const Color(0xFF6C63FF); // default purple color

    if (label == 'Delivery') {
      // Convert bool to a more user-friendly display
      if (value is bool) {
        if (value) {
          displayValue = 'Available';
          valueColor = Colors.green;
        } else {
          displayValue = 'Unavailable';
          valueColor = Colors.redAccent;
        }
      } else if (value.toString().toLowerCase() == 'true') {
        displayValue = 'Available';
        valueColor = Colors.green;
      } else if (value.toString().toLowerCase() == 'false') {
        displayValue = 'Unavailable';
        valueColor = Colors.redAccent;
      }
    }

    return Column(
      children: [
        Text(
          displayValue,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
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
          // Handle Delivery Setting separately
          if (setting['title'] == 'Delivery Settings') {
            return SwitchListTile(
              title: Text(setting['title'] as String),
              secondary: Container(
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
              value: _hasDelivery, // ← a local bool state variable
              onChanged: (bool value) async {
                setState(() => _hasDelivery = value);

                try {
                  await _shopService.updateShopProfile(
                    shopId: _currentShopId!,
                    delivery: value, // your DB column must be `delivery`
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Delivery enabled for your shop.'
                            : 'Delivery disabled for your shop.',
                      ),
                    ),
                  );

                  _loadShopDetails(); // refresh UI
                } catch (e) {
                  setState(() => _hasDelivery = !_hasDelivery); // revert
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update delivery status: $e')),
                  );
                }
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey,
            );
          }

          // Default ListTile for others
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
              switch (setting['title']) {
                case 'Edit Shop Profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopProfileEditor(
                        nameController: _nameController,
                        categoryController: _categoryController,
                        emailController: _emailController,
                        imageUrlController: _imageUrlController,
                        shopId: _currentShopId!,
                        onProfileUpdated: _loadShopDetails,
                      ),
                    ),
                  );
                  break;

                case 'Change Business Hrs':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessHoursEditor(
                        shopId: _currentShopId!,
                        onProfileUpdated: _loadShopDetails,
                      ),
                    ),
                  );
                  break;

                case 'Payment Methods':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentMethodsSelector(
                        shopId: _currentShopId!,
                        onProfileUpdated: _loadShopDetails,
                      ),
                    ),
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

  Widget _buildPaymentMethods() {
    // Safely grab the map (it may be null)
    final Map<String, dynamic>? pm = _shopDetails?.paymentMethods;

    if (pm == null || pm.isEmpty) {
      return const Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No payment methods set',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final method = pm['method'] as String? ?? 'unknown';
    final List<Widget> details = [];

    switch (method) {
      case 'mpesa_send':
        details.addAll([
          _buildPaymentDetailRow('Method', 'M-PESA Send Money'),
          _buildPaymentDetailRow('Mobile Number', pm['mobile_number']?.toString() ?? 'N/A'),
        ]);
        break;

      case 'paybill':
        details.addAll([
          _buildPaymentDetailRow('Method', 'Paybill'),
          _buildPaymentDetailRow('Paybill Number', pm['paybill_number']?.toString() ?? 'N/A'),
          _buildPaymentDetailRow('Account Number', pm['account_number']?.toString() ?? 'N/A'),
        ]);
        break;

      case 'pochi':
        details.addAll([
          _buildPaymentDetailRow('Method', 'Pochi La Biashara'),
          _buildPaymentDetailRow('Pochi Number', pm['pochi_number']?.toString() ?? 'N/A'),
        ]);
        break;

      default:
        details.add(const Text(
          'Unknown payment method',
          style: TextStyle(color: Colors.redAccent),
        ));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 12),
            ...details,
          ],
        ),
      ),
    );
  }


  Widget _buildPaymentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

    File? selectedImage;
    bool isUploadingImage = false;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> _pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                setDialogState(() {
                  selectedImage = File(pickedFile.path);
                });
              }
            }

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
                    // 🖼️ Image preview section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to add product image'),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(selectedImage!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
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

                    // ✅ Close the dialog *first* before starting async operations
                    Navigator.of(dialogContext).pop();

                    // ✅ Perform upload and add product outside the dialog context
                    if (!mounted) return;
                    setState(() => _isLoading = true);

                    try {
                      String? imageUrl;
                      if (selectedImage != null) {
                        imageUrl = await _productService.uploadProductImage(selectedImage!);
                      }

                      await _productService.addProduct(
                        shopId: _currentShopId!,
                        name: name,
                        price: price,
                        description: descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                        imageFile: selectedImage,
                      );

                      await _loadProducts();

                      _addActivity(
                        Activity(
                          color: Colors.indigoAccent,
                          icon: Icons.add_box,
                          title: 'New Product Added: $name',
                          time: DateTime.now(),
                        ),
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
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                    }
                  },
                ),
              ],
            );
          },
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
                setDialogState(() {
                  _selectedImage = File(pickedFile.path);
                  // reset uploaded url if user changes image again
                  _updatedImageUrl = null;
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error saving picking the image: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          // local helper to upload image and update dialog state
          Future<String?> _uploadProductImage(File imageFile) async {
            try {
              setDialogState(() => _isUploading = true);
              final String? uploadedUrl = await _productService.uploadProductImage(imageFile);

              if (uploadedUrl != null) {
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

