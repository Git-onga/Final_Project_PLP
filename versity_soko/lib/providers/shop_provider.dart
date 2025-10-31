import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shop_model.dart';

class ShopProvider {
  final supabase = Supabase.instance.client;

  /// ✅ Create a new shop (only one per user)
  Future<void> createShop({
    required String name,
    required String description,
    required String category,
    required String email,
    required String phone,
    required bool delivery,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userId = user.id;

    // 1️⃣ Check if the user already owns a shop
    final existingShop = await supabase
        .from('shops')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existingShop != null) {
      throw Exception("You already own a shop.");
    }

    // 2️⃣ Create new shop data
    final shop = {
      'name': name,
      'description': description,
      'category': category,
      'email': email,
      'phone': phone,
      'delivery': delivery,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    // 3️⃣ Insert into Supabase
    final response = await supabase.from('shops').insert(shop).select().maybeSingle();

    if (response == null) {
      throw Exception("Failed to create shop");
    }

    print('✅ Shop created successfully: ${response['name']}');
  }

  /// 🔍 Fetch the current user's shop
  Future<ShopModel?> fetchUserShop() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('⚠️ No user logged in.');
        return null;
      }

      // Query the shops table for the logged-in user
      final response = await supabase
          .from('shops')
          .select()
          .eq('user_id', user.id)
          .maybeSingle(); // returns a single map or null

      if (response == null) {
        print('⚠️ No shop found for user ${user.id}');
        return null;
      }

      // Convert response to ShopModel
      final shop = ShopModel.fromJson(response);
      print('✅ Shop fetched successfully: ${shop.name}');
      return shop;
    } catch (e, stack) {
      print('❌ Error fetching user shop: $e');
      print(stack);
      return null;
    }
  }

  /// 🚫 Delete user's shop
  Future<void> deleteUserShop() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final response = await supabase
        .from('shops')
        .delete()
        .eq('user_id', user.id);

    print('✅ Shop deleted successfully for user ${user.id}');
  }
}
