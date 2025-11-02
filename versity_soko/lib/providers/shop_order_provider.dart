// class ShopOrderModel {
//   final String id;
//   final String userOrderId;
//   final String shopId;
//   final String items;        // keep as string or change to JSON/List if you prefer
//   final double totalPrice;
//   final String status;
//   final DateTime date;

//   ShopOrderModel({
//     required this.id,
//     required this.userOrderId,
//     required this.shopId,
//     required this.items,
//     required this.totalPrice,
//     required this.status,
//     required this.date,
//   });

//   /// Create a copy with optional replacements (useful for immutability)
//   ShopOrderModel copyWith({
//     String? id,
//     String? userOrderId,
//     String? shopId,
//     String? items,
//     double? totalPrice,
//     String? status,
//     DateTime? date,
//   }) {
//     return ShopOrderModel(
//       id: id ?? this.id,
//       userOrderId: userOrderId ?? this.userOrderId,
//       shopId: shopId ?? this.shopId,
//       items: items ?? this.items,
//       totalPrice: totalPrice ?? this.totalPrice,
//       status: status ?? this.status,
//       date: date ?? this.date,
//     );
//   }

//   /// From Supabase / JSON -> model
//   factory ShopOrderModel.fromJson(Map<String, dynamic> json) {
//     // Support both 'date' and 'created_at' naming from DB
//     final rawDate = json['date'] ?? json['created_at'];
//     DateTime parsedDate;
//     if (rawDate == null) {
//       parsedDate = DateTime.now();
//     } else if (rawDate is String) {
//       parsedDate = DateTime.parse(rawDate);
//     } else {
//       parsedDate = DateTime.parse(rawDate.toString());
//     }

//     return ShopOrderModel(
//       id: json['id']?.toString() ?? '',
//       userOrderId: json['user_order_id']?.toString() ?? '',
//       shopId: json['shop_id']?.toString() ?? '',
//       items: json['items']?.toString() ?? '',
//       totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
//       status: (json['status'] as String?)?.toLowerCase() ?? 'received',
//       date: parsedDate,
//     );
//   }

//   /// Model -> JSON for Supabase
//   Map<String, dynamic> toJson() {
//     return {
//       if (userOrderId.isNotEmpty) 'user_order_id': userOrderId,
//       if (shopId.isNotEmpty) 'shop_id': shopId,
//       'items': items,
//       'total_price': totalPrice,
//       'status': status,
//       'date': date.toIso8601String(),
//     };
//   }
// }
