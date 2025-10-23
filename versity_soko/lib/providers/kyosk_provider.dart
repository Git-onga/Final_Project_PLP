import 'package:flutter/material.dart';

// Product Status Enum
enum ProductStatus {
  active,
  draft,
  outOfStock,
}

// Product Model
class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;
  final String description;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isService;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isService = false,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    String? description,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isService,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isService: isService ?? this.isService,
    );
  }
}

// Shop Statistics Model
class ShopStats {
  final int totalOrders;
  final double revenue;
  final int followers;
  final int showcases;
  final int totalProducts;
  final int lowStockItems;
  final int outOfStockItems;

  const ShopStats({
    required this.totalOrders,
    required this.revenue,
    required this.followers,
    required this.showcases,
    required this.totalProducts,
    required this.lowStockItems,
    required this.outOfStockItems,
  });

  ShopStats copyWith({
    int? totalOrders,
    double? revenue,
    int? followers,
    int? showcases,
    int? totalProducts,
    int? lowStockItems,
    int? outOfStockItems,
  }) {
    return ShopStats(
      totalOrders: totalOrders ?? this.totalOrders,
      revenue: revenue ?? this.revenue,
      followers: followers ?? this.followers,
      showcases: showcases ?? this.showcases,
      totalProducts: totalProducts ?? this.totalProducts,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      outOfStockItems: outOfStockItems ?? this.outOfStockItems,
    );
  }
}

// Kiosk Provider
class KioskProvider with ChangeNotifier {
  List<Product> _products = [];
  ShopStats _shopStats = const ShopStats(
    totalOrders: 156,
    revenue: 2845.00,
    followers: 1200,
    showcases: 45,
    totalProducts: 0,
    lowStockItems: 0,
    outOfStockItems: 0,
  );

  List<Product> get products => _products;
  ShopStats get shopStats => _shopStats;

  KioskProvider() {
    _loadSampleProducts();
    _updateShopStats();
  }

  void _loadSampleProducts() {
    _products = [
      Product(
        id: '1',
        name: 'Summer Floral Dress',
        price: 49.99,
        stock: 15,
        imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=200',
        category: 'Clothing',
        description: 'Beautiful summer dress with floral pattern',
        status: ProductStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isService: false,
      ),
      Product(
        id: '2',
        name: 'Wireless Headphones',
        price: 129.99,
        stock: 8,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200',
        category: 'Electronics',
        description: 'High-quality wireless headphones with noise cancellation',
        status: ProductStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        isService: false,
      ),
      Product(
        id: '3',
        name: 'Designer Handbag',
        price: 89.99,
        stock: 0,
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=200',
        category: 'Fashion',
        description: 'Luxury designer handbag made from genuine leather',
        status: ProductStatus.outOfStock,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        isService: false,
      ),
      Product(
        id: '4',
        name: 'Smart Watch',
        price: 199.99,
        stock: 3,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200',
        category: 'Electronics',
        description: 'Feature-rich smartwatch with health monitoring',
        status: ProductStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        isService: false,
      ),
      Product(
        id: '5',
        name: 'Custom Tailoring Service',
        price: 25.00,
        stock: 999, // High stock for services
        imageUrl: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=200',
        category: 'Service',
        description: 'Professional tailoring services for perfect fit',
        status: ProductStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isService: true,
      ),
      Product(
        id: '6',
        name: 'Phone Repair Service',
        price: 50.00,
        stock: 999,
        imageUrl: 'https://images.unsplash.com/photo-1567581935884-3349723552ca?w=200',
        category: 'Service',
        description: 'Professional phone repair for all brands',
        status: ProductStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isService: true,
      ),
      Product(
        id: '7',
        name: 'Vintage Denim Jacket',
        price: 65.99,
        stock: 2,
        imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=200',
        category: 'Clothing',
        description: 'Vintage style denim jacket with unique wash',
        status: ProductStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isService: false,
      ),
      Product(
        id: '8',
        name: 'Personal Styling Consultation',
        price: 75.00,
        stock: 999,
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=200',
        category: 'Service',
        description: 'One-on-one personal styling session',
        status: ProductStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        isService: true,
      ),
    ];
    
    _updateShopStats();
    notifyListeners();
  }

  void _updateShopStats() {
    final totalProducts = _products.length;
    final lowStockItems = _products.where((p) => p.stock > 0 && p.stock <= 5 && !p.isService).length;
    final outOfStockItems = _products.where((p) => p.stock == 0 && !p.isService).length;

    _shopStats = _shopStats.copyWith(
      totalProducts: totalProducts,
      lowStockItems: lowStockItems,
      outOfStockItems: outOfStockItems,
    );
  }

  // Product Management Methods
  void addProduct(Product product) {
    _products.add(product);
    _updateShopStats();
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      _updateShopStats();
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _updateShopStats();
    notifyListeners();
  }

  void updateProductStatus(String productId, ProductStatus newStatus) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateProductStock(String productId, int newStock) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final newStatus = newStock > 0 ? ProductStatus.active : ProductStatus.outOfStock;
      _products[index] = _products[index].copyWith(
        stock: newStock,
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      _updateShopStats();
      notifyListeners();
    }
  }

  void duplicateProduct(String productId) {
    final product = _products.firstWhere((p) => p.id == productId);
    final duplicatedProduct = product.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${product.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _products.add(duplicatedProduct);
    _updateShopStats();
    notifyListeners();
  }

  // Service Management Methods
  void addService({
    required String name,
    required double price,
    required String description,
    String imageUrl = 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=200',
  }) {
    final newService = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      stock: 999, // Services have high stock by default
      imageUrl: imageUrl,
      category: 'Service',
      description: description,
      status: ProductStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isService: true,
    );
    
    addProduct(newService);
  }

  // Shop Stats Management
  void updateShopStats(ShopStats newStats) {
    _shopStats = newStats;
    notifyListeners();
  }

  void incrementFollowers() {
    _shopStats = _shopStats.copyWith(followers: _shopStats.followers + 1);
    notifyListeners();
  }

  void addOrder(double amount) {
    _shopStats = _shopStats.copyWith(
      totalOrders: _shopStats.totalOrders + 1,
      revenue: _shopStats.revenue + amount,
    );
    notifyListeners();
  }

  // Filter Methods
  List<Product> getActiveProducts() {
    return _products.where((p) => p.status == ProductStatus.active).toList();
  }

  List<Product> getDraftProducts() {
    return _products.where((p) => p.status == ProductStatus.draft).toList();
  }

  List<Product> getOutOfStockProducts() {
    return _products.where((p) => p.status == ProductStatus.outOfStock).toList();
  }

  List<Product> getServices() {
    return _products.where((p) => p.isService).toList();
  }

  List<Product> getPhysicalProducts() {
    return _products.where((p) => !p.isService).toList();
  }

  List<Product> getLowStockProducts() {
    return _products.where((p) => p.stock > 0 && p.stock <= 5 && !p.isService).toList();
  }

  // Search Methods
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Analytics Methods
  double getTotalInventoryValue() {
    return _products.fold(0.0, (sum, product) => sum + (product.price * product.stock));
  }

  int getTotalItemsSold() {
    // This would typically come from order history
    // For demo, we'll calculate based on some assumptions
    return _shopStats.totalOrders * 2; // Assuming 2 items per order on average
  }

  double getAverageOrderValue() {
    return _shopStats.totalOrders > 0 ? _shopStats.revenue / _shopStats.totalOrders : 0;
  }

  // Category Management
  List<String> getProductCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Map<String, int> getCategoryStats() {
    final Map<String, int> stats = {};
    for (final product in _products) {
      stats[product.category] = (stats[product.category] ?? 0) + 1;
    }
    return stats;
  }
}