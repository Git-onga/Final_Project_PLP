class Product {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final String? description;
  final DateTime createdAt;
  final String? imageUrl;

  Product({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    this.description,
    required this.createdAt,
    required this.imageUrl,
  });

  // Convert from Supabase JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      shopId: json['shop_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      imageUrl: json['image_url']?.toString() ??
        'https://picsum.photos/100/100?random=1', // fallback image
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'price': price,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  Product copyWith({
    String? id,
    String? shopId,
    String? name,
    double? price,
    String? description,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? imageUrl,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, shopId: $shopId}';
  }
}