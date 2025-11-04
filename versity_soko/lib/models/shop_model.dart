class ShopModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String email;
  final String phone;
  final bool delivery;
  final String userId;
  final DateTime createdAt;

  // 🆕 New fields
  final String? imageUrl;
  final Map<String, dynamic>? paymentMethods;
  final Map<String, dynamic>? businessHours;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.email,
    required this.phone,
    required this.delivery,
    required this.userId,
    required this.createdAt,
    this.imageUrl,
    this.paymentMethods,
    this.businessHours,
  });

  /// ✅ From Supabase JSON
  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      delivery: json['delivery'] ?? false,
      userId: json['user_id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),

      // 🆕 New fields (safe null handling)
      imageUrl: json['image_url'] ?? '',
      paymentMethods: json['payment_methods'] != null
          ? Map<String, dynamic>.from(json['payment_methods'])
          : {},
      businessHours: json['business_hours'] != null
          ? Map<String, dynamic>.from(json['business_hours'])
          : {},
    );
  }

  /// ✅ To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'email': email,
      'phone': phone,
      'delivery': delivery,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      // 🆕 New fields
      'image_url': imageUrl,
      'payment_methods': paymentMethods,
      'business_hours': businessHours,
    };
  }
}
