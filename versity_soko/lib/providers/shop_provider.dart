import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/shop_model.dart';
import '../services/local_storage_service.dart';

class ShopProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  ShopModel? _shop;
  bool _loading = false;

  ShopModel? get shop => _shop;
  bool get loading => _loading;

  /// ✅ Create a new shop (only one per user)
  Future<void> createShop({
    required String name,
    required String description,
    required String category,
    required String email,
    required String phone,
    required bool delivery,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userId = user.id;

    // 1️⃣ Check if the user already owns a shop
    final existingShop = await _supabase
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
    final response =
        await _supabase.from('shops').insert(shop).select().maybeSingle();

    if (response == null) {
      throw Exception("Failed to create shop");
    }

    _shop = ShopModel.fromJson(response);
    await LocalStorageService.cacheShops([response]);
    notifyListeners();

    print('✅ Shop created successfully: ${_shop!.name}');
  }

  /// 🔍 Fetch the current user's shop
  Future<void> fetchUserShop() async {
    _loading = true;
    notifyListeners();

    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('⚠️ No user logged in.');
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        try {
          final response = await _supabase
              .from('shops')
              .select()
              .eq('user_id', user.id)
              .maybeSingle();

          if (response != null) {
            _shop = ShopModel.fromJson(response);
            await LocalStorageService.cacheShops([response]); // ✅ cache it
            print('✅ Shop fetched online and cached.');
          } else {
            print('⚠️ No shop found for user.');
            _shop = null;
          }
        } catch (e) {
          print('⚠️ Online fetch failed, trying cached: $e');
          await _loadCachedShop();
        }
      } else {
        print('📴 Offline mode → loading cached shop.');
        await _loadCachedShop();
      }
    } catch (e, stack) {
      print('❌ Error fetching user shop: $e');
      print(stack);
    }

    _loading = false;
    notifyListeners();
  }

  /// 🗂️ Load cached shop
  Future<void> _loadCachedShop() async {
    final cachedData = await LocalStorageService.getCachedShops();
    if (cachedData != null && cachedData.isNotEmpty) {
      _shop = ShopModel.fromJson(cachedData.first);
      print('✅ Loaded cached shop: ${_shop!.name}');
    } else {
      print('⚠️ No cached shop data found.');
    }
  }

  /// 🚫 Delete user's shop
  Future<void> deleteUserShop() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _supabase.from('shops').delete().eq('user_id', user.id);
    _shop = null;

    final prefs = await LocalStorageService.getData('cached_shops');
    if (prefs != null) {
      await LocalStorageService.saveData('cached_shops', []);
    }

    print('✅ Shop deleted successfully for user ${user.id}');
    notifyListeners();
  }
}
