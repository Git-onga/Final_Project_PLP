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
  });

  /// ✅ From Supabase JSON
  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'].toString(), // Works whether int or string
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      delivery: json['delivery'] ?? false,
      userId: json['user_id'] ?? '', // match Supabase column name
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
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
    };
  }
}
