import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/showcase_model.dart';
import 'dart:io';

class ShowcaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> hasShowcases() async {
    try {
      final response = await _supabase
          .from('show_case')
          .select('id') // only fetch ID for performance
          .limit(1);

      print('✅ Checked showcases existence');
      return response.isNotEmpty;
    } catch (e) {
      print('🚨 Error checking showcases: $e');
      return false;
    }
  }


  /// ✅ Fetch all showcases
  Future<List<ShowcaseModel>> fetchShowcases() async {
    try {
      final response = await _supabase
          .from('show_case')
          .select('*')
          .order('created_at', ascending: false);

      final List showcases = response as List;
      return showcases.map((data) => ShowcaseModel.fromJson(data)).toList();
    } catch (e) {
      print('🚨 Error fetching showcases: $e');
      return [];
    }
  }

  /// ✅ Check if current user owns a shop
  Future<String?> _getUserShopId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('shops')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      return response?['id']?.toString();
    } catch (e) {
      print('🚨 Error getting user shop: $e');
      return null;
    }
  }

  /// ✅ Upload showcase (only if user has a shop)
  Future<ShowcaseModel?> uploadShowcase({
    required File imageFile,
    String? caption,
    DateTime? expiresAt,
  }) async {
    try {
      final shopId = await _getUserShopId();
      if (shopId == null) {
        throw Exception('User does not have a shop — cannot upload showcase.');
      }

      // Step 1: Upload image to Supabase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'showcases/$shopId/$fileName';

      final storageResponse = await _supabase.storage
          .from('showcase') // name of your storage bucket
          .upload(storagePath, imageFile);

      // Step 2: Get public URL
      final mediaUrl = _supabase.storage
          .from('showcase')
          .getPublicUrl(storagePath);

      // Step 3: Insert showcase record into the database
      final insertData = {
        'shop_id': shopId,
        'media_url': mediaUrl,
        'caption': caption,
        'expires_at': expiresAt?.toIso8601String(),
      };

      final response =
          await _supabase.from('show_case').insert(insertData).select().single();

      print('✅ Showcase uploaded successfully');
      return ShowcaseModel.fromJson(response);
    } catch (e) {
      print('🚨 Error uploading showcase: $e');
      return null;
    }
  }

}
