import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // _products = [
    //   ProductModel(
    //     id: '1',
    //     name: 'Laptop Backpack',
    //     description: 'Durable laptop backpack for students',
    //     price: 25.99,
    //     category: 'Accessories',
    //     shopId: '1',
    //     stock: 50,
    //     rating: 4.5,
    //     reviewCount: 45,
    //   ),
    //   ProductModel(
    //     id: '2',
    //     name: 'Wireless Mouse',
    //     description: 'Ergonomic wireless mouse',
    //     price: 15.99,
    //     category: 'Electronics',
    //     shopId: '2',
    //     stock: 30,
    //     rating: 4.2,
    //     reviewCount: 32,
    //   ),
    // ];
    
    _isLoading = false;
    notifyListeners();
  }

//   void addProduct(ProductModel product) {
//     _products.add(product);
//     notifyListeners();
//   }
}