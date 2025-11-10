import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ShowCaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchShowcases(String userId) async {
    try {
      // 1️⃣ Get all shop_ids that this user follows
      final response = await supabase
          .from('shop_followers')
          .select('shop_id')
          .eq('user_id', userId)
          .timeout(const Duration(seconds: 5));

      if (response.isEmpty) return [];

      final shopIds = response.map((e) => e['shop_id']).toList();

      if (shopIds.isEmpty) return [];

      // 2️⃣ Fetch showcases + shop details in a single joined query
      final showcases = await supabase
          .from('show_case')
          .select('id, media_url, caption, created_at, shop_id, shops(name, image_url)')
          .inFilter('shop_id', shopIds)
          .order('created_at', ascending: false)
          .limit(10)
          .timeout(const Duration(seconds: 15));
      return showcases;
    } on TimeoutException {
      print('⚠️ Supabase request timed out. Retrying...');
      await Future.delayed(const Duration(seconds: 2));
      return fetchShowcases(userId);
    } catch (e) {
      print('❌ Error fetching showcases: $e');
      return [];
    }
  }



  Future<void> handleShowcaseTap(
    Map<String, dynamic> showcase,
    String userId,
  ) async {
    final supabase = Supabase.instance.client;
    final showcaseId = showcase['id'];

    try {
      // Check if the user already viewed this showcase
      final existing = await supabase
          .from('showcase_viewer')
          .select('id')
          .eq('user_id', userId)
          .eq('showcase_id', showcaseId)
          .maybeSingle();

      if (existing == null) {
        // Add viewer record
        await supabase.from('showcase_viewer').insert({
          'user_id': userId,
          'showcase_id': showcaseId,
        });

        // Increment viewer count
        await supabase.rpc('increment_viewer_count', params: {
          'showcase_id': showcaseId,
        });
      }
    } catch (e) {
      print('❌ Error handling showcase tap: $e');
    }
  }


}