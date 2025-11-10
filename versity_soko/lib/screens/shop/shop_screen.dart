import 'package:flutter/material.dart';
import 'package:versity_soko/models/shop_model.dart';
import 'package:versity_soko/screens/shop/cart_screen.dart';
import '../../services/retrive_shop_details.dart';
import '../shop/shop_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  final String shopId; // Pass the shop ID when navigating to this screen
  const ShopScreen({super.key, required this.shopId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopModel? shop;
  bool isLoading = true;
  List<ShopModel> shops = [];
  final ShopDetailsService _shopService = ShopDetailsService();
  List<ShopModel> _filteredShops = [];  // Shops filtered by category
  int selectedCategoryIndex = 0;      
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    final fetchedShops = await _shopService.getAllShops();
    setState(() {
      shops = fetchedShops;
      isLoading = false;
      _filteredShops = List.from(shops);
    });
  }

  @override
	Widget build(BuildContext context) {
		return Scaffold(
		backgroundColor: isDark
                ? Colors.black
                : Colors.white,
		body: SingleChildScrollView(
      child: SafeArea(
        child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						_buildAppBar(),
						// SizedBox(height: 8,),
            // Top Shops Section
						_buildTopShopsSection(),
            SizedBox(height: 24,),
						// Filter Tags
						_buildFilterTags(),
            SizedBox(height: 24,),
						// Shop Grid
						_buildShopGridSection(),
					],
				),
      )
			
			),
		);
	}

	Widget _buildAppBar() {
		return SafeArea(
      child: Padding(
        padding:  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: isDark ? [Color.fromARGB(255, 169, 123, 215), Color.fromARGB(255, 126, 146, 237)] : [Colors.blue[700]!, Colors.purple[600]!]  ,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                child: const Text(
                  'Soko',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            Spacer(),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark? const [
                      Color(0xFF1E1A33), Color(0xFF2C254A)
                    ]:const [
                      Color.fromARGB(255, 241, 238, 246),
                      Color.fromARGB(255, 225, 230, 244),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: isDark ? Colors.white : Colors.grey, // Keep this neutral to contrast with gradient
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            )

            
          ],
        ),
      )
    );
	}


	Widget _buildFilterTags() {
  final categories = [
    'All Categories',
    'Clothes',
    'Beauty Accessories',
    'Electronics',
    'Books',
    'Food & Drinks',
    'Stationery',
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Filter your Shop Search',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[900],
            ),
          ),
        ),

        // Filter tags
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 4),
              ...List.generate(categories.length, (index) {
                final isSelected = selectedCategoryIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // ✅ Update selected index & apply category filter globally
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                        _applyCategoryFilter(categories[index]);
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [Colors.green[500]!, Colors.green[600]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [Colors.white, Colors.blue[50]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.green[400]! : Colors.blue[100]!,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_getCategoryIcon(categories[index]) != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  _getCategoryIcon(categories[index]),
                                  size: 14,
                                  color: isSelected ? Colors.white : Colors.blue[600],
                                ),
                              ),
                            Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
            ],
          ),
        ),

        // Selected category + shop count indicator
        if (selectedCategoryIndex >= 0)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              children: [
                // Selected filter badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Icon(
                        Icons.filter_alt_rounded,
                        color: Colors.green[600],
                        size: 14,
                      ),
                      Text(
                        'Filtered: ${categories[selectedCategoryIndex]}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // ✅ Reset to "All Categories"
                          setState(() {
                            selectedCategoryIndex = 0;
                          });
                          _applyCategoryFilter('All Categories');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.green[600],
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Shop count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: Colors.green[600],
                        size: 16,
                      ),
                      Text(
                        '${_filteredShops.length} shops found',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

void _applyCategoryFilter(String selectedCategory) {
  setState(() {
    if (selectedCategory == 'All Categories') {
      _filteredShops = List.from(shops); // Show all shops
    } else {
      _filteredShops = shops.where((shop) {
        final shopCategory = shop.category?.toLowerCase() ?? '';
        final normalizedSelectedCategory = selectedCategory.toLowerCase();
        
        // Enhanced matching logic
        return shopCategory.contains(normalizedSelectedCategory) ||
              _isCategorySimilar(shopCategory, normalizedSelectedCategory);
      }).toList();
    }
  });
}

/// Enhanced category matching with better fuzzy logic
bool _isCategorySimilar(String shopCategory, String selectedCategory) {
  // Category mapping for better matching
  final categoryMap = {
    'clothes': ['clothing', 'fashion', 'apparel', 'wear', 'outfit', 'garment'],
    'beauty accessories': ['beauty', 'cosmetics', 'makeup', 'skincare', 'make-up', 'salon'],
    'electronics': ['electronic', 'tech', 'technology', 'gadget', 'device', 'digital'],
    'books': ['book', 'literature', 'reading', 'novel', 'publication'],
    'food & drinks': ['food', 'drink', 'restaurant', 'cafe', 'beverage', 'dining', 'meal'],
    'stationery': ['stationary', 'office', 'writing', 'pen', 'paper', 'notebook'],
  };

  // Check if selected category has related terms
  for (final mainCategory in categoryMap.keys) {
    if (selectedCategory.contains(mainCategory)) {
      // Check if shop category matches any related term
      return categoryMap[mainCategory]!.any((term) => shopCategory.contains(term));
    }
    
    // Also check if any related term matches the selected category
    if (categoryMap[mainCategory]!.any((term) => selectedCategory.contains(term))) {
      return shopCategory.contains(mainCategory) || 
             categoryMap[mainCategory]!.any((term) => shopCategory.contains(term));
    }
  }

  // Word similarity check
  final selectedWords = selectedCategory.split(' ');
  final shopWords = shopCategory.split(' ');
  
  // Check if any word matches
  for (final selectedWord in selectedWords) {
    if (selectedWord.length > 3) { // Only check words with meaningful length
      for (final shopWord in shopWords) {
        if (shopWord.contains(selectedWord) || selectedWord.contains(shopWord)) {
          return true;
        }
      }
    }
  }

  return false;
}


  // Helper method to get icons for categories
  IconData? _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all categories':
        return Icons.all_inclusive_rounded;
      case 'clothes':
        return Icons.checkroom_rounded;
      case 'beauty accessories':
        return Icons.face_retouching_natural_rounded;
      case 'electronics':
        return Icons.electrical_services_rounded;
      case 'books':
        return Icons.menu_book_rounded;
      case 'food & drinks':
        return Icons.restaurant_rounded;
      case 'stationery':
        return Icons.edit_note_rounded;
      default:
        return null;
    }
  }



  /// Enhanced category matching with better fuzzy logic
  bool _matchesCategory(String shopCategory, String selectedCategory) {
    // Direct match
    if (shopCategory.contains(selectedCategory) || selectedCategory.contains(shopCategory)) {
      return true;
    }

    // Category mapping for better matching
    final categoryMap = {
      'clothes': ['clothing', 'fashion', 'apparel', 'wear', 'outfit', 'garment'],
      'make-up accessories': ['makeup', 'cosmetics', 'beauty', 'skincare', 'make-up'],
      'electronics': ['electronic', 'tech', 'technology', 'gadget', 'device', 'digital'],
      'books': ['book', 'literature', 'reading', 'novel', 'publication'],
      'food & drinks': ['food', 'drink', 'restaurant', 'cafe', 'beverage', 'dining', 'meal'],
      'stationery': ['stationary', 'office', 'writing', 'pen', 'paper', 'notebook'],
    };

    // Check if selected category has related terms
    for (final mainCategory in categoryMap.keys) {
      if (selectedCategory.contains(mainCategory) || 
          mainCategory.contains(selectedCategory)) {
        // Check if shop category matches any related term
        return categoryMap[mainCategory]!.any((term) => shopCategory.contains(term));
      }
      
      // Also check if any related term matches the selected category
      if (categoryMap[mainCategory]!.any((term) => selectedCategory.contains(term))) {
        return shopCategory.contains(mainCategory) || 
              categoryMap[mainCategory]!.any((term) => shopCategory.contains(term));
      }
    }

    // Word similarity check
    final selectedWords = selectedCategory.split(' ');
    final shopWords = shopCategory.split(' ');
    
    // Check if any word matches
    for (final selectedWord in selectedWords) {
      if (selectedWord.length > 3) { // Only check words with meaningful length
        for (final shopWord in shopWords) {
          if (shopWord.contains(selectedWord) || selectedWord.contains(shopWord)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // Add this state variable at the top of your widget class
  int _selectedCategoryIndex = 0;


  Widget _buildTopShopsSection() {
    final List<ShopModel> _topShops = shops.where((shop) => shop.followers >= 100).toList();
    if (_topShops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced header with see all button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "🔥 Top Shops",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] :Colors.black87,
                ),
              ),
              
              
            ],
          ),
        ),
        SizedBox(height: 8),
        // Enhanced shop cards with more information
        SizedBox(
          height: 200, // Increased height for better content
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topShops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final shop = _topShops[index];
              
              return _buildShopCard(shop, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopCard(ShopModel shop, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailScreen(shopId: shop.id),
          ),
        );
      },
      child: Container(
        width: 160, // Slightly wider for better content
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [
              const Color(0xFF1E1A33), const Color(0xFF2C254A)
            ]:[
              const Color.fromARGB(255, 241, 238, 246),
              const Color.fromARGB(255, 225, 230, 244),
            ]
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop image with badge and favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    shop.imageUrl ?? 'https://via.placeholder.com/160x100',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.store, color: Colors.grey, size: 40),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Top shop badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'TOP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Shop info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop name and verified badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.grey[300] : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Category
                  Text(
                    shop.category,
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Rating and followers
                  Row(
                    children: [
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: shop.delivery
                              ? const Color.fromARGB(255, 225, 235, 255) // light blue background
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: shop.delivery
                              ? Border.all(color: const Color.fromARGB(255, 180, 210, 255))
                              : null,
                        ),
                        child: shop.delivery
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.delivery_dining,
                                    color: Color(0xFF1E88E5),
                                    size: 12,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Available',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(), // nothing when false
                      ),                    
                      const Spacer(),
                      Container(
                        // margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: Colors.green[600],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatFollowers(shop.followers),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
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
          ],
        ),
      ),
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}k';
    }
    return followers.toString();
  }

	Widget _buildShopGridSection() {
    if (isLoading) {
      return _buildLoadingGrid();
    }

    if (_filteredShops.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredShops.length,
            itemBuilder: (context, index) {
              final shop = _filteredShops[index];
             
              return _buildEnhancedShopCard(shop, index);
            },
          ),
        ],
      ),
    );
  }


  Widget _buildEnhancedShopCard(ShopModel shop, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
        : [Color(0xFFF1EEF6), Color(0xFFE1E6F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Color(0xFF1E1A33),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopDetailScreen(shopId: shop.id),
                ),
              );
            },
            splashColor: Colors.green.withOpacity(0.2),
            highlightColor: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product images carousel
                    _buildImageCarousel( shop),
                    
                    // Shop info section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Shop name and category
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop.name ?? 'Unnamed Shop',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.grey[300] : Colors.grey[900],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  shop.category ?? 'General Store',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),

                            // Rating and followers row
                            Row(
                              children: [
                                // Rating
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: shop.delivery
                                        ? const Color.fromARGB(255, 225, 235, 255) // light blue background
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: shop.delivery
                                        ? Border.all(color: const Color.fromARGB(255, 180, 210, 255))
                                        : null,
                                  ),
                                  child: shop.delivery
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.delivery_dining,
                                              color: Color(0xFF1E88E5),
                                              size: 12,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Available',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1565C0),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(), // nothing when false
                                ), 
                                
                                const Spacer(),
                                
                                // Followers with green accent
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green[100]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_alt_rounded,
                                        color: Colors.green[600],
                                        size: 10,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _formatFollowers(shop.followers),
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
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
                    ),
                  ],
                ),
                
                // Top shop badge with gradient
                if (shop.followers >= 1000)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber[600]!, Colors.orange[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'TOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(ShopModel shop) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          // Main image
         ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: (shop.imageUrl == null || shop.imageUrl!.isEmpty)
              ? Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[100]!, Colors.purple[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: Colors.green[400],
                    size: 40,
                  ),
                )
              : Image.network(
                  shop.imageUrl!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.purple[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                ),
        ),

        ],
      ),
    );
  }


  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 24,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[200]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.purple[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [Colors.blue[600]!, Colors.purple[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: const Text(
              'No Shops Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter to find more shops',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[500]!, Colors.green[600]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Refresh or search action
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortFilterOptions() {
  // Implement sort and filter dialog
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.purple[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add your sort and filter options here
            ListTile(
              leading: Icon(Icons.sort, color: Colors.blue[600]),
              title: Text('Sort by Rating'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.green[600]),
              title: Text('Sort by Followers'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {},
            ),
          ],
        ),
      );
    },
  );
}

}


