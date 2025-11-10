import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyProducts = 'cached_products';
  static const String _keyShops = 'cached_shops';

  // Save data locally
  static Future<void> saveData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(key, jsonString);
  }

  // Get saved data
  static Future<List<dynamic>?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // Specific helpers
  static Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    await saveData(_keyProducts, products);
  }

  static Future<List<dynamic>?> getCachedProducts() async {
    return await getData(_keyProducts);
  }

  static Future<void> cacheShops(List<Map<String, dynamic>> shops) async {
    await saveData(_keyShops, shops);
  }

  static Future<List<dynamic>?> getCachedShops() async {
    return await getData(_keyShops);
  }
}
