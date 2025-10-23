class ShopModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String university;
  final double rating;
  final int reviewCount;
  final String? imageUrl;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.university,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrl,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      university: json['university'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'university': university,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
    };
  }
}

// Corrected Dummy Data matching the original constructor
final List<ShopModel> dummyShops = [
  ShopModel(
    id: '1',
    name: 'TechGadgets KyU',
    description: 'Your one-stop shop for the latest tech accessories, gadgets, and electronics. Best prices for students!',
    ownerId: 'user_tech1',
    university: 'Kirinyaga University',
    rating: 4.8,
    reviewCount: 156,
    imageUrl: 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400',
  ),
  ShopModel(
    id: '2',
    name: 'Campus Fashion Hub',
    description: 'Trendy and affordable fashion for students. From casual wear to formal outfits for presentations.',
    ownerId: 'user_fashion2',
    university: 'Kirinyaga University',
    rating: 4.5,
    reviewCount: 89,
    imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
  ),
  ShopModel(
    id: '3',
    name: 'BookWorm Corner',
    description: 'Textbooks, novels, and stationery at student-friendly prices. Buy, sell, and exchange books!',
    ownerId: 'user_books3',
    university: 'Kirinyaga University',
    rating: 4.7,
    reviewCount: 203,
    imageUrl: 'https://images.unsplash.com/photo-1535905557558-676c0e69d8f6?w=400',
  ),
  ShopModel(
    id: '4',
    name: 'SnackAttack',
    description: 'Late-night snacks, beverages, and quick bites delivered to your hostel. Open until 11 PM!',
    ownerId: 'user_food4',
    university: 'Kirinyaga University',
    rating: 4.6,
    reviewCount: 178,
    imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
  ),
  ShopModel(
    id: '5',
    name: 'Fitness Gear Pro',
    description: 'Quality sports equipment, gym wear, and fitness accessories for active students.',
    ownerId: 'user_fitness5',
    university: 'Kirinyaga University',
    rating: 4.4,
    reviewCount: 67,
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
  ),
  ShopModel(
    id: '6',
    name: 'Artisan Crafts',
    description: 'Handmade crafts, gifts, and unique items created by talented students. Support local artists!',
    ownerId: 'user_arts6',
    university: 'Kirinyaga University',
    rating: 4.9,
    reviewCount: 94,
    imageUrl: 'https://images.unsplash.com/photo-1605721911519-3dfeb3be25e7?w=400',
  ),
  ShopModel(
    id: '7',
    name: 'Mobile Solutions',
    description: 'Phone repairs, accessories, and mobile services. Fast and reliable service for all brands.',
    ownerId: 'user_mobile7',
    university: 'Kirinyaga University',
    rating: 4.3,
    reviewCount: 112,
    imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
  ),
  ShopModel(
    id: '8',
    name: 'Green Thumb Plants',
    description: 'Indoor plants, succulents, and gardening supplies to brighten up your study space.',
    ownerId: 'user_plants8',
    university: 'Kirinyaga University',
    rating: 4.7,
    reviewCount: 45,
    imageUrl: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400',
  ),
  ShopModel(
    id: '9',
    name: 'Study Buddy Supplies',
    description: 'Everything you need for productive study sessions - from notebooks to desk organizers.',
    ownerId: 'user_study9',
    university: 'Kirinyaga University',
    rating: 4.5,
    reviewCount: 78,
    imageUrl: 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400',
  ),
  ShopModel(
    id: '10',
    name: 'Campus Print Hub',
    description: 'Printing, binding, and photocopying services. Fast turnaround for assignments and projects.',
    ownerId: 'user_print10',
    university: 'Kirinyaga University',
    rating: 4.6,
    reviewCount: 134,
    imageUrl: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400',
  ),
];

// If you need additional properties like categories, you can create an extension or helper class
class ShopHelper {
  static String getCategory(ShopModel shop) {
    final categoryMap = {
      '1': 'Electronics',
      '2': 'Fashion',
      '3': 'Books & Stationery',
      '4': 'Food & Beverages',
      '5': 'Sports & Fitness',
      '6': 'Arts & Crafts',
      '7': 'Electronics',
      '8': 'Home & Garden',
      '9': 'Books & Stationery',
      '10': 'Services',
    };
    return categoryMap[shop.id] ?? 'General';
  }

  static List<String> getTags(ShopModel shop) {
    final tagsMap = {
      '1': ['Tech', 'Gadgets', 'Electronics', 'Affordable'],
      '2': ['Fashion', 'Clothing', 'Trendy', 'Student Style'],
      '3': ['Books', 'Textbooks', 'Stationery', 'Academic'],
      '4': ['Food', 'Snacks', 'Delivery', 'Late Night'],
      '5': ['Fitness', 'Sports', 'Gym', 'Equipment'],
      '6': ['Handmade', 'Crafts', 'Art', 'Unique Gifts'],
      '7': ['Phone Repair', 'Accessories', 'Mobile', 'Tech Support'],
      '8': ['Plants', 'Gardening', 'Home Decor', 'Succulents'],
      '9': ['Study', 'Organization', 'Supplies', 'Academic'],
      '10': ['Printing', 'Photocopy', 'Binding', 'Services'],
    };
    return tagsMap[shop.id] ?? ['General'];
  }

  static int getFollowerCount(ShopModel shop) {
    final followerMap = {
      '1': 1247,
      '2': 892,
      '3': 1567,
      '4': 2103,
      '5': 445,
      '6': 678,
      '7': 556,
      '8': 334,
      '9': 789,
      '10': 923,
    };
    return followerMap[shop.id] ?? 0;
  }

  static bool isVerified(ShopModel shop) {
    final verifiedShops = ['1', '2', '3', '6', '9', '10'];
    return verifiedShops.contains(shop.id);
  }
}

// Categories for filtering
final List<String> shopCategories = [
  'All',
  'Electronics',
  'Fashion',
  'Books & Stationery',
  'Food & Beverages',
  'Sports & Fitness',
  'Arts & Crafts',
  'Home & Garden',
  'Services',
];

// Helper function to get shops by category
List<ShopModel> getShopsByCategory(String category) {
  if (category == 'All') return dummyShops;
  return dummyShops.where((shop) => ShopHelper.getCategory(shop) == category).toList();
}

// Helper function to get trending shops
// List<ShopModel> getTrendingShops() {
//   return dummyShops
//     ..sort((a, b) {
//       final aScore = a.rating * 100 + ShopHelper.getFollowerCount(a) / 100;
//       final bScore = b.rating * 100 + ShopHelper.getFollowerCount(b) / 100;
//       return bScore.compareTo(aScore);
//     })
//     .take(6)
//     .toList();
// }

// Helper function to search shops
List<ShopModel> searchShops(String query) {
  if (query.isEmpty) return dummyShops;
  return dummyShops.where((shop) {
    return shop.name.toLowerCase().contains(query.toLowerCase()) ||
           shop.description.toLowerCase().contains(query.toLowerCase()) ||
           ShopHelper.getTags(shop).any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
  }).toList();
}