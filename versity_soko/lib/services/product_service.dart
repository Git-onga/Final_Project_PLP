import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:versity_soko/models/product_model.dart';

class ProductService with ChangeNotifier {
  final SupabaseClient _supabase;
  final List<Product> _products = [];
  final bool _loading = false;

  ProductService() : _supabase = Supabase.instance.client;

  List<Product> get products => _products;
  bool get loading => _loading;

  // Fetch products and update state
  Future<List<Product>> fetchProducts(String shopId) async {
    print('fetchProducts in product_service file: $shopId');
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Add product and update state
  Future<Product> addProduct({
    required String shopId,
    required String name,
    required double price,
    String? description,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .insert({
            'shop_id': shopId,
            'name': name,
            'price': price,
            'description': description,
          })
          .select()
          .single();

      final newProduct = Product.fromJson(response);
      _products.insert(0, newProduct);
      notifyListeners();
      print('new poroduct: $newProduct');
      return newProduct;
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product and refresh state
  Future<void> updateProductInList(Product updatedProduct) async {
  try {
    await _supabase
        .from('products')
        .update(updatedProduct.toJson())
        .eq('id', updatedProduct.id);

    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  } catch (e) {
    print('Error updating product: $e');
    throw Exception('Failed to update product: $e');
  }
}

  // Delete product and update state
  Future<void> removeProduct(String productId) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', productId);

      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }
}