import '../models/shop_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopDetailsService {
  final SupabaseClient database = Supabase.instance.client;

  /// ✅ Retrieve all shops from Supabase
  Future<List<ShopModel>> getAllShops() async {
    
    try {
      final response = await database.from('shops').select('*');
      print(response);
      if (response.isEmpty) return [];

      return response.map((shop) {
        print('Successfully fetched shop: ${shop}');
        return ShopModel.fromJson(Map<String, dynamic>.from(shop));
        
      }).toList();
    } catch (e) {
      print('❌ Error fetching shops: $e');
      return [];
    }
  }

  /// ✅ Print shops (for debugging)
  Future<void> printShops() async {
    try {
      final shops = await getAllShops();
      for (final shop in shops) {
        print('🛒 ${shop.name} - ${shop.category}');
      }
    } catch (e) {
      print('❌ Error printing shops: $e');
    }
  }
}
