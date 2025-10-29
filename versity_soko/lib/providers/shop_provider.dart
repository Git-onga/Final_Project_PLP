import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/shop_model.dart';

class ShopProvider {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref(); // Root reference

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
    final shopRef = _database.child('shops/$userId');

    // 1️⃣ Check if the user already owns a shop
    final existingShop = await shopRef.get();
    if (existingShop.exists) {
      throw Exception("You already own a shop.");
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

    // 3️⃣ Save the shop data to Realtime Database
    await shopRef.set(shop.toJson());
  }

  /// 🔍 Fetch the current user's shop
  Future<ShopModel?> fetchUserShop() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final shopRef = _database.child('shops/${user.uid}');
    final snapshot = await shopRef.get();

    if (!snapshot.exists) return null;

    final map = Map<String, dynamic>.from(snapshot.value as Map);
    return ShopModel.fromMap(snapshot.key!, map);
  }

  /// 🚫 Delete user's shop
  Future<void> deleteUserShop() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final shopRef = _database.child('shops/${user.uid}');
    await shopRef.remove();
  }
}
