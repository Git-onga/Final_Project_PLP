import 'package:flutter/material.dart';
import '../models/shop_model.dart';

class ShopProvider with ChangeNotifier {
  List<ShopModel> _shops = [];
  bool _isLoading = false;
  String? _error;

  List<ShopModel> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadShops() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    _shops = [
      ShopModel(
        id: '1',
        name: 'Campus Store',
        description: 'Your one-stop campus shop',
        ownerId: '1',
        university: 'University of Nairobi',
        rating: 4.5,
        reviewCount: 120,
      ),
      ShopModel(
        id: '2',
        name: 'Tech Hub',
        description: 'Electronics and gadgets',
        ownerId: '2',
        university: 'Kenyatta University',
        rating: 4.2,
        reviewCount: 85,
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  void addShop(ShopModel shop) {
    _shops.add(shop);
    notifyListeners();
  }
}