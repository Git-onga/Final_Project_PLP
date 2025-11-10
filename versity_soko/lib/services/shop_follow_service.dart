import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopFollowService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch all shop IDs the user follows
  Future<List<String>> fetchFollowedShops({required String userId}) async {
    try {
      print('Fetching ...');
      final response = await supabase
          .from('shop_followers')
          .select('shop_id')
          .eq('user_id', userId);

      if (response == null) return [];
      print('... Fetched Done ');
      print('... $response');

      // Extract shop_id from response
      return List<String>.from(
        response.map((e) => e['shop_id'].toString()),
      );
    } catch (e) {
      debugPrint('❌ Error fetching followed shops: $e');
      return [];
    }
  }

  /// Checks if the given user follows a specific shop,
  /// and if true, returns the shop details from the 'shops' table.
  Future<Map<String, dynamic>?> getFollowedShopDetails({
    required String userId,
    required String shopId,
  }) async {
    try {
      // Step 1: Check if the user follows this shop
      final followResponse = await supabase
          .from('shop_followers')
          .select()
          .eq('user_id', userId)
          .eq('shop_id', shopId)
          .maybeSingle();

      // If not following, return null
      if (followResponse == null) {
        return null;
      }

      // Step 2: Fetch the shop details
      final shopResponse = await supabase
          .from('shops')
          .select()
          .eq('id', shopId)
          .maybeSingle();

      if (shopResponse != null) {
        return Map<String, dynamic>.from(shopResponse);
      }

      return null;
    } catch (e) {
      print('❌ Error fetching followed shop details: $e');
      return null;
    }
  }

  /// Add a new follower
  /// Returns true if added, false if already following
  Future<bool> addFollower({required String userId, required String shopId}) async {
    try {
      // Check if user already follows the shop
      final existing = await supabase
          .from('shop_followers')
          .select()
          .eq('user_id', userId)
          .eq('shop_id', shopId)
          .maybeSingle();

      if (existing != null) {
        debugPrint('User already follows this shop');
        return false; // Already following
      }

      // Insert new follower
      await supabase.from('shop_followers').insert({
        'user_id': userId,
        'shop_id': shopId,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Follower added successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding follower: $e');
      return false;
    }
  }

  /// Remove a follower (optional)
  Future<bool> removeFollower({required String userId, required String shopId}) async {
    try {
      final count = await supabase
          .from('shop_followers')
          .delete()
          .eq('user_id', userId)
          .eq('shop_id', shopId);

      return (count != null && count > 0);
    } catch (e) {
      debugPrint('❌ Error removing follower: $e');
      return false;
    }
  }
}
