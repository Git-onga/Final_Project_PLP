import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:versity_soko/models/product_model.dart';

class ProductService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Product> _products = [];
  bool _loading = false;

  List<Product> get products => _products;
  bool get loading => _loading;

  // Fetch products by shop
  Future<List<Product>> fetchProducts(String shopId) async {
    try {
      _setLoading(true);

      final response = await _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Upload product image to Supabase Storage
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'product/$fileName';

      await _supabase.storage.from('product').upload(filePath, imageFile);
      return _supabase.storage.from('product').getPublicUrl(filePath);
    } catch (e) {
      return null;
    }
  }

  // Add a new product (with optional image)
  Future<Product> addProduct({
    required String shopId,
    required String name,
    required double price,
    String? description,
    File? imageFile,
  }) async {
    try {
      final imageUrl = await _getImageUrl(imageFile);

      final response = await _supabase
          .from('products')
          .insert({
            'shop_id': shopId,
            'name': name,
            'price': price,
            'description': description,
            'image_url': imageUrl,
          })
          .select()
          .single();

      final newProduct = Product.fromJson(response);
      _products.insert(0, newProduct);
      notifyListeners();

      return newProduct;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product (with optional image)
  Future<void> updateProductInList(Product updatedProduct, {File? imageFile}) async {
    try {
      final imageUrl = await _getImageUrl(imageFile, currentUrl: updatedProduct.imageUrl);

      final productData = updatedProduct.toJson()..['image_url'] = imageUrl;

      await _supabase
          .from('products')
          .update(productData)
          .eq('id', updatedProduct.id);

      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct.copyWith(imageUrl: imageUrl);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
  Future<void> removeProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Helper method to get image URL
  Future<String> _getImageUrl(File? imageFile, {String? currentUrl}) async {
    if (imageFile != null) {
      final uploadedUrl = await uploadProductImage(imageFile);
      return uploadedUrl ?? currentUrl ?? _defaultImageUrl;
    }
    return currentUrl ?? _defaultImageUrl;
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Default image URL constant
  static const String _defaultImageUrl = 'https://picsum.photos/100/100?random=1';
}