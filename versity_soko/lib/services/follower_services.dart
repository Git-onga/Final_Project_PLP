import 'package:supabase_flutter/supabase_flutter.dart';

class ShopFollowerService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Check if a user is following a shop
  Future<bool> isFollowing({
    required String userId,
    required String shopId,
  }) async {
    final response = await supabase
        .from('shop_followers')
        .select()
        .eq('user_id', userId)
        .eq('shop_id', shopId)
        .maybeSingle();
        
    return response != null;
  }

  /// Adds a follower to the shop_followers table.
  /// Prevents duplicates — a user can only follow a shop once.
  Future<bool> addFollower({
    required String userId,
    required String shopId,
  }) async {
    try {
      // Check if user already follows the shop
      final existing = await supabase
          .from('shop_followers')
          .select()
          .eq('user_id', userId)
          .eq('shop_id', shopId)
          .maybeSingle();

      if (existing == true) {
        // Already following
        print('User already follows this shop');
        return false;
      }

      // Insert new follower
      await supabase.from('shop_followers').insert({
        'user_id': userId,
        'shop_id': shopId,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Follower added successfully');
      return true;
    } catch (e) {
      print('❌ Error adding follower: $e');
      return false;
    }
  }

  /// Remove a follower
  Future<bool> unfollowShop({
    required String userId,
    required String shopId,
  }) async {
    try {
      final alreadyFollowing = await isFollowing(userId: userId, shopId: shopId);
      if (!alreadyFollowing) return false;

      await supabase
          .from('shop_followers')
          .delete()
          .eq('user_id', userId)
          .eq('shop_id', shopId);

      return true;
    } catch (e) {
      print('Error unfollowing shop: $e');
      return false;
    }
  }
}
