import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final SupabaseClient supabase = Supabase.instance.client;
  List<CartItem> get cartItems => _cartItems;

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
    notifyListeners();
  }


  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    final index = _cartItems.indexWhere((c) => c.product.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(Product product) {
    final index = _cartItems.indexWhere((c) => c.product.id == product.id);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems[index].quantity = 1;
      }
      notifyListeners();
    }
  }

  double get totalPrice =>
    _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));


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

}
