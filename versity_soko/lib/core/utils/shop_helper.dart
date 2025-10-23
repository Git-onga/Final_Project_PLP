import '../../models/shop_model.dart';

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