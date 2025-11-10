import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'],
      );
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final SupabaseClient supabase = Supabase.instance.client;

  List<CartItem> get cartItems => _cartItems;

  CartProvider() {
    _loadCartFromLocal();
  }

  /// 🔄 Load cart data from Hive storage
  Future<void> _loadCartFromLocal() async {
    final box = Hive.box('cartBox');
    final saved = box.get('cartItems');
    if (saved != null) {
      final List decoded = jsonDecode(saved);
      _cartItems.clear();
      _cartItems.addAll(decoded.map((e) => CartItem.fromJson(e)).toList());
      notifyListeners();
    }
  }

  /// 💾 Save cart to Hive storage
  Future<void> _saveCartToLocal() async {
    final box = Hive.box('cartBox');
    final encoded = jsonEncode(_cartItems.map((e) => e.toJson()).toList());
    await box.put('cartItems', encoded);
  }

  void addToCart(Product product) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      _cartItems.add(CartItem(product: product, quantity: 1));
    } else {
      existingItem.quantity++;
    }

    _saveCartToLocal();
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    _saveCartToLocal();
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _saveCartToLocal();
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    final index = _cartItems.indexWhere((c) => c.product.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity++;
      _saveCartToLocal();
      notifyListeners();
    }
  }

  void decreaseQuantity(Product product) {
    final index = _cartItems.indexWhere((c) => c.product.id == product.id);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      }
      _saveCartToLocal();
      notifyListeners();
    }
  }

  double get totalPrice => _cartItems.fold(
      0, (sum, item) => sum + (item.product.price * item.quantity));

  Future<void> checkoutCart(String userId) async {
    for (var item in _cartItems) {
      await supabase.from('shop_orders').insert({
        'user_id': userId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'total_price': item.product.price * item.quantity,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    clearCart();
  }

  Future<bool> addFollower({
    required String userId,
    required String shopId,
  }) async {
    try {
      final existing = await supabase
          .from('shop_followers')
          .select()
          .eq('user_id', userId)
          .eq('shop_id', shopId)
          .maybeSingle();

      if (existing != null) return false;

      await supabase.from('shop_followers').insert({
        'user_id': userId,
        'shop_id': shopId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding follower: $e');
      return false;
    }
  }
}
