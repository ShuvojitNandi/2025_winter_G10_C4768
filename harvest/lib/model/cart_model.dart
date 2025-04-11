import 'package:cloud_firestore/cloud_firestore.dart';


class CartItem {
  final String? id;             
  final String userId;           
  final String vendorId;         
  final String productId;        
  final int quantity;            //quantity the user added
  final double unitPrice;        // unit price at the time of adding
  final double totalPrice;       // quantity * unitPrice
  final bool isPaid;             
  final Timestamp timestamp;     


  CartItem({
    this.id,
    required this.userId,
    required this.vendorId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.isPaid,
    required this.timestamp,
  });


  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vendorId': vendorId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'isPaid': isPaid,
      'timestamp': timestamp,
    };
  }


  static CartItem fromMap(DocumentSnapshot doc) {
  final map = doc.data() as Map<String, dynamic>;
  return CartItem(
    id: doc.id, 
    userId: map['userId'] ?? '',
    vendorId: map['vendorId'] ?? '',
    productId: map['productId'] ?? '',
    quantity: map['quantity'] ?? 0,
    unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    isPaid: map['isPaid'] ?? false,
    timestamp: map['timestamp'] ?? Timestamp.now(),
  );
}
}
