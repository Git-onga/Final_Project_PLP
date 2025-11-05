import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class ShopProfileService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? _shopData;
  Map<String, dynamic>? get shopData => _shopData;

  bool _loading = false;
  bool get loading => _loading;

  /// Fetch shop details by shopId
  Future<Map<String, dynamic>?> fetchShopProfile(String shopId) async {
    try {
      _loading = true;
      notifyListeners();

      final response = await _supabase
          .from('shops')
          .select()
          .eq('id', shopId)
          .single();

      _shopData = response;
      return response; // ✅ Return the shop data so other widgets can use it
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching shop profile: $e');
      }
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  /// Update shop details (name, description, phone, etc.)
  Future<bool> updateShopProfile({
    required String shopId,
    String? name,
    String? category,
    String? profileImageUrl,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      final updateData = <String, dynamic>{};
      if (name != null && name.isNotEmpty) updateData['name'] = name;
      if (category!= null && category.isNotEmpty) updateData['category'] = category;
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) updateData['image_url'] = profileImageUrl;

      await _supabase
          .from('shops')
          .update(updateData)
          .eq('id', shopId);

      // Refresh local data after update
      await fetchShopProfile(shopId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating shop profile: $e');
      }
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateShopBusinessHrs({
      required String shopId,
      required TimeOfDay openingTime,
      required TimeOfDay closingTime,
      required Map<String, bool> openDays,
    }) async {
      // Validate inputs
      try {
      _loading = true;
      notifyListeners();

      // Prepare JSONB object
      final businessHours = {
        'open_time': '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}',
        'close_time': '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}',
        'open_days': openDays,
      };

      await _supabase
          .from('shops')
          .update({'business_hours': businessHours})
          .eq('id', shopId);

      // Optionally refresh local shop data
      await fetchShopProfile(shopId);

      return true;

    } catch (e) {
      // Use conditional compilation instead of kDebugMode
      assert(() {
        print('❌ Error updating shop business hours: $e');
        return true;
      }());
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Helper method to validate business hours
  bool _validateBusinessHours(TimeOfDay openTime, TimeOfDay closeTime) {
    if (openTime.hour < 0 || openTime.hour > 23 || closeTime.hour < 0 || closeTime.hour > 23) {
      if (kDebugMode) {
        print('❌ Error: Business hours must be between 00:00 and 23:59');
      }
      return false;
    }

    // Check if close time is after open time (allowing for 24-hour operations)
    final openInMinutes = openTime.hour * 60 + openTime.minute;
    final closeInMinutes = closeTime.hour * 60 + closeTime.minute;
    
    if (closeInMinutes <= openInMinutes) {
      if (kDebugMode) {
        print('❌ Error: Close time must be after open time');
      }
      return false;
    }

    return true;
  }

  Future<bool> updatePaymentMethod({
      required String shopId,
      required Map<String, dynamic> paymentDetails,
    }) async {
      try {
        _loading = true;
        notifyListeners();

        // Validate inputs
        if (shopId.isEmpty) {
          throw ArgumentError('Shop ID cannot be empty');
        }

        if (paymentDetails.isEmpty) {
          throw ArgumentError('Payment details cannot be empty');
        }

        // Update payment methods in the database
        final response = await _supabase
            .from('shops')
            .update({
              'payment_methods': paymentDetails,
            })
            .eq('id', shopId)
            .select();

        if (response.isEmpty) {
          throw Exception('Shop not found with ID: $shopId');
        }

        // Refresh local shop data
        await fetchShopProfile(shopId);

        // Debug logging
        assert(() {
          print('✅ Payment methods updated successfully for shop: $shopId');
          print('📦 Payment details: $paymentDetails');
          return true;
        }());

        return true;

      } on PostgrestException catch (e) {
        assert(() {
          print('❌ Database error updating payment methods: ${e.message}');
          print('Details: ${e.details}');
          return true;
        }());
        return false;
      } catch (e) {
        assert(() {
          print('❌ Error updating payment methods: $e');
          return true;
        }());
        return false;
      } finally {
        _loading = false;
        notifyListeners();
      }
    }

  // Helper method to validate open days
  bool _validateOpenDays(Map<String, bool> openDays) {
    const validDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    if (openDays.isEmpty) {
      if (kDebugMode) {
        print('❌ Error: At least one day must be selected');
      }
      return false;
    }

    for (final day in openDays.keys) {
      if (!validDays.contains(day)) {
        if (kDebugMode) {
          print('❌ Error: Invalid day format: $day. Use: $validDays');
        }
        return false;
      }
    }

    // Check if at least one day is open
    if (!openDays.values.any((isOpen) => isOpen)) {
      if (kDebugMode) {
        print('❌ Error: At least one day must be open for business');
      }
      return false;
    }

    return true;
  }

  // Helper method to format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Upload profile image to Supabase Storage and return the public URL
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String shopId,
  }) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'shops/$shopId/$fileName';

      await _supabase.storage
          .from('shop_profile')
          .upload(filePath, imageFile);

      final publicUrl = _supabase.storage
          .from('shop_profile')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading profile image: $e');
      }
      return null;
    }
  }

  /// Delete existing image before uploading a new one (optional)
  Future<void> deleteOldImage(String imageUrl) async {
    try {
      final path = Uri.parse(imageUrl).pathSegments.skip(1).join('/');
      await _supabase.storage.from('shop_profile').remove([path]);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error deleting old image: $e');
      }
    }
  }
}
