class ShopModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String email;
  final String phone;
  final bool delivery;
  final String userId;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.email,
    required this.phone,
    required this.delivery,
    required this.userId, 
    required DateTime createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'email': email,
      'phone': phone,
      'delivery': delivery,
      'userId': userId,
    };
  }

  factory ShopModel.fromMap(String id, Map<String, dynamic> map) {
    return ShopModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      delivery: map['delivery'] ?? false,
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String())
    );
  }
}
