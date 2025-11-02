class ShopOrderWithProductModel {
final String id;
final String userOrderId;
final String userId;
final String productId;
final int quantity;
final double totalPrice;
final String status;
final DateTime createdAt;

// Merged from products table
final String productName;
final double productPrice;
final String productImageUrl;

  ShopOrderWithProductModel({
  required this.id,
  required this.userOrderId,
  required this.userId,
  required this.productId,
  required this.quantity,
  required this.totalPrice,
  required this.status,
  required this.createdAt,
  required this.productName,
  required this.productPrice,
  required this.productImageUrl,
  });

  factory ShopOrderWithProductModel.fromJson(Map<String, dynamic> json) {
  final productsData = json['products'] as Map<String, dynamic>?;

  return ShopOrderWithProductModel(
    id: json['id']?.toString() ?? '',
    userOrderId: json['user_order_id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    productId: json['product_id']?.toString() ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    status: json['status']?.toString() ?? 'pending',
    createdAt: DateTime.parse(
      json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    ),
    productName: productsData?['name']?.toString() ?? 'Unknown Product',
    productPrice: (productsData?['price'] as num?)?.toDouble() ?? 0.0,
    productImageUrl: productsData?['image_url']?.toString() ?? '',
  );

  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_order_id': userOrderId,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'product_name': productName,
      'product_price': productPrice,
      'product_image_url': productImageUrl,
    };
  }

  ShopOrderWithProductModel copyWith({
    String? id,
    String? userOrderId,
    String? userId,
    String? productId,
    int? quantity,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    String? productName,
    double? productPrice,
    String? productImageUrl,
  }) {
    return ShopOrderWithProductModel(
      id: id ?? this.id,
      userOrderId: userOrderId ?? this.userOrderId,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
    );
  }
}
