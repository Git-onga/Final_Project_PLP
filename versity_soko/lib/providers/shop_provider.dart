import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shop_model.dart';

class ShopProvider {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  /// ✅ Create a new shop (only one per user)
  Future<void> createShop({
    required String name,
    required String description,
    required String category,
    required String email,
    required String phone,
    required bool delivery,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userId = user.uid;
    final shopFileRef = _storage.ref().child('shops/$userId.json');

    try {
      // 1️⃣ Check if shop already exists
      await shopFileRef.getMetadata();
      throw Exception("You already own a shop.");
    } catch (e) {
      // File doesn't exist → continue only if it's a not-found error
      if (e is! FirebaseException || e.code != 'object-not-found') {
        rethrow;
      }
    }

    // 2️⃣ Create new shop data
    final shop = ShopModel(
      id: userId,
      name: name,
      description: description,
      category: category,
      email: email,
      phone: phone,
      delivery: delivery,
      userId: userId,
      createdAt: DateTime.now(),
    );

    // Convert to JSON string
    final jsonData = jsonEncode(shop.toJson());

    // 3️⃣ Upload JSON to Firebase Storage
    await shopFileRef.putString(
      jsonData,
      metadata: SettableMetadata(contentType: 'application/json'),
    );
  }

  /// 🔍 Fetch the current user's shop
  Future<ShopModel?> fetchUserShop() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final shopFileRef = _storage.ref().child('shops/${user.uid}.json');

    try {
      final data = await shopFileRef.getData();
      if (data == null) return null;

      final jsonStr = utf8.decode(data);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      return ShopModel.fromMap(map['id'] ?? user.uid, map); // Fixed: removed the incorrect cast to String
    } catch (e) {
      // No file found or other error
      return null;
    }
  }

  /// 🚫 Delete user's shop
  Future<void> deleteUserShop() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final shopFileRef = _storage.ref().child('shops/${user.uid}.json');
    await shopFileRef.delete();
  }
}