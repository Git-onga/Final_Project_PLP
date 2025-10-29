import 'package:firebase_database/firebase_database.dart';
import '../models/shop_model.dart';

class ShopDetailsService {
  final DatabaseReference _shopsDbRef = FirebaseDatabase.instance.ref().child('shops');

  /// Retrieve shop details by shop ID
  Future<List<ShopModel>> getAllShops() async {
    final snapshot = await _shopsDbRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.entries.map((e) {
      final shopData = Map<String, dynamic>.from(e.value as Map);
      return ShopModel.fromJson(shopData);
    }).toList();

  }
  void printShops() {
    final _shopsPrint = _shopsDbRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value;
      return data;
    });
    print(
      _shopsPrint
    );
  }
 
}
