import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/cart_model.dart';


class CartController {
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');



  Future<void> addOrUpdateCartItem(CartItem item) async {
    final query = await _cartCollection
        .where('userId', isEqualTo: item.userId)
        .where('productId', isEqualTo: item.productId)
        .where('isPaid', isEqualTo: false)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final existingDoc = query.docs.first;
      // final existingItem = CartItem.fromMap(existingDoc);
      final newQuantity = item.quantity;

      if (newQuantity == 0) {
        await _cartCollection.doc(existingDoc.id).delete();
      } else {
        final updatedItem = CartItem(
          id: existingDoc.id,
          userId: item.userId,
          vendorId: item.vendorId,
          productId: item.productId,
          quantity: newQuantity,
          unitPrice: item.unitPrice,
          totalPrice: newQuantity * item.unitPrice,
          isPaid: false,
          timestamp: Timestamp.now(),
        );
        await _cartCollection.doc(existingDoc.id).update(updatedItem.toMap());
      }
    } else {
      if (item.quantity > 0) {
        await _cartCollection.add(item.toMap());
      }
    }
  }



 
  Future<void> deleteCartItem(String cartItemId) async {
    await _cartCollection.doc(cartItemId).delete();
  }

 
  Future<List<CartItem>> getUserCartItems(String userId) async {
    final query = await _cartCollection
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: false)
        .get();
    return query.docs.map((doc) => CartItem.fromMap(doc)).toList();
  }


  Future<Map<String, List<CartItem>>> getGroupedCartItemsByVendor(String userId) async {
    final items = await getUserCartItems(userId);
    final Map<String, List<CartItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.vendorId, () => []).add(item);
    }
    return grouped;
  }


  Stream<List<CartItem>> streamUserCart(String userId) {
    return _cartCollection
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CartItem.fromMap(doc)).toList());
  }


  Future<void> markItemAsPaid(String cartItemId) async {
    await _cartCollection.doc(cartItemId).update({'isPaid': true});
  }

  
  Future<void> clearUserCart(String userId) async {
    final query = await _cartCollection
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }
}
