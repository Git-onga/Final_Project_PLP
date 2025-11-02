import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shop_order_model.dart';

class ShopOrderService with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<ShopOrderWithProductModel> _orders = [];
  List<ShopOrderWithProductModel> get orders => _orders;

  bool _loading = false;
  bool get loading => _loading;

  /// Fetch all shop orders for a given shop
  Future<List<ShopOrderWithProductModel>> fetchShopOrders() async {
    _loading = true;
    notifyListeners();

    try {
      // Get the current user from Supabase auth
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.id;
      print('Fetching orders for user: $userId');

      final data = await supabase
          .from('shop_orders')
          .select('''
            *,
            products:product_id (
              name,
              price
            )
          ''')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);
      
      
      final listData = data as List<dynamic>? ?? [];
      final orders = listData.map((json) => ShopOrderWithProductModel.fromJson(json)).toList();
      
      _orders = orders;
      _loading = false;
      notifyListeners();
      
      return orders;
    } catch (e) {
      _loading = false;
      notifyListeners();
      throw Exception('Failed to fetch shop orders: $e');
    }
  }

  Future<List<ShopOrderWithProductModel>> fetchShopOrdersWithProducts() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final data = await supabase
          .from('shop_orders')
          .select('''
            *,
            products:product_id (
              name,
              price
            )
          ''')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);
      
      final listData = data as List<dynamic>? ?? [];
      return listData.map((json) => ShopOrderWithProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch shop orders with products: $e');
    }
  }

  /// Add a new shop order
  Future<void> addShopOrder(ShopOrderWithProductModel order) async {
    _loading = true;
    notifyListeners();

    final response = await supabase
        .from('shop_orders')
        .insert([order.toJson()]);

    if (response.error != null) {
      _loading = false;
      notifyListeners();
      throw response.error!;
    }

    ///Optionally, fetch again to refresh list
    
    //   await fetchShopOrders(order.userId);
    
  }

  /// Update status of a shop order
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await supabase
          .from('shop_orders')
          .update({'status': newStatus})
          .eq('id', orderId);
      
      print('Order $orderId status updated to $newStatus');
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }
  /// Delete a shop order
  Future<void> deleteShopOrder(String orderId) async {
    _loading = true;
    notifyListeners();

    final response = await supabase
        .from('shop_orders')
        .delete()
        .eq('id', orderId);

    if (response.error != null) {
      _loading = false;
      notifyListeners();
      throw response.error!;
    }

    _orders.removeWhere((o) => o.id == orderId);

    _loading = false;
    notifyListeners();
  }
}
