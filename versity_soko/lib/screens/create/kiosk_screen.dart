import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/kyosk_provider.dart';
import '../home/home_screen.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          backgroundColor: const Color(0xFF6C63FF), // Purple primary
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
          ],
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
              Tab(icon: Icon(Icons.inventory_2), text: 'Inventory'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Products'),
              Tab(icon: Icon(Icons.store), text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildInventoryTab(),
            _buildProductsTab(),
            _buildProfileTab(),
          ],
        ),
        // bottomNavigationBar: CustomBottomNavBar(
        //   currentIndex: 0,
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
              // Quick Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Orders',
                      value: '156',
                      change: '+12%',
                      icon: Icons.shopping_cart,
                      color: const Color(0xFF4CAF50), // Green
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Revenue',
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
                      title: 'Showcases',
                      value: '45',
                      change: '+5%',
                      icon: Icons.visibility,
                      color: const Color(0xFF00BCD4), // Cyan
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              _buildSectionHeader('Recent Activity', Icons.history),
              const SizedBox(height: 16),
              _buildActivityList(),

              const SizedBox(height: 24),

              // Top Products
              _buildSectionHeader('Top Products', Icons.star),
              const SizedBox(height: 16),
              _buildTopProducts(kioskProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryTab() {
    return Consumer<KioskProvider>(
      builder: (context, kioskProvider, child) {
        final products = kioskProvider.products;
        
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
                  _buildInventoryStat('Total Items', '${products.length}'),
                  _buildInventoryStat('Low Stock', '3'),
                  _buildInventoryStat('Out of Stock', '2'),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildInventoryItem(products[index], kioskProvider);
                },
              ),
            ),
          ],
        );
      },
    );
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
              _buildSectionHeader('Shop Settings', Icons.settings),
              const SizedBox(height: 16),
              _buildSettingsList(),

              const SizedBox(height: 24),

              // Business Hours
              _buildSectionHeader('Business Hours', Icons.access_time),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 8),
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
      child: Column(
        children: activities.map((activity) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity['color'] as Color? ?? Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(activity['icon'] as IconData, color: Colors.white, size: 20),
            ),
            title: Text(activity['title'] as String),
            subtitle: Text(activity['time'] as String),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProducts(KioskProvider kioskProvider) {
    final topProducts = kioskProvider.products.take(3).toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: topProducts.map((product) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            trailing: Chip(
              label: Text('${product.stock} left'),
              backgroundColor: product.stock > 10 ? Colors.green[100] : Colors.orange[100],
            ),
          );
        }).toList(),
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

  Widget _buildInventoryItem(Product product, KioskProvider kioskProvider) {
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
        subtitle: Text('Stock: ${product.stock}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.red),
              onPressed: () => _updateStock(product, kioskProvider, product.stock - 1),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () => _updateStock(product, kioskProvider, product.stock + 1),
            ),
          ],
        ),
      ),
    );
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