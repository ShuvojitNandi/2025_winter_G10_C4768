import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/vendor_model.dart';

class VendorService {
  final CollectionReference vendorCollection =
      FirebaseFirestore.instance.collection('vendors');

  Future<DocumentReference<Object?>> addVendor(Vendor vendor) async {
    return await vendorCollection.add(vendor.toMap());
  }

  Future<void> updateVendor(Vendor vendor) async {
    return await vendorCollection.doc(vendor.id).update(vendor.toMap());
  }

  Future<void> deleteVendor(String id) async {
    return await vendorCollection.doc(id).delete();
  }

  Stream<Vendor?> getVendor(String vendorId) {
    return vendorCollection.doc(vendorId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Vendor.fromMap(doc);
    });
  }

  Future<String> uploadStoreImage(File imageFile, String vendorId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('store_images/$vendorId');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload store image: $e");
    }
  }

  CollectionReference getVendorProducts(String vendorId) {
    return vendorCollection.doc(vendorId).collection('vendor_products');
  }

  CollectionReference getVendorMessages(String vendorId) {
    return vendorCollection.doc(vendorId).collection('messages');
  }
}

class CategoryService {
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categories');


  Future<dynamic> addCategory(Category category) async {
  final snapshot = await categoryCollection
      .where('name', isEqualTo: category.name)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return "Category exists, add your product.";
  }

  return await categoryCollection.add(category.toMap());
  }


  Future<void> updateCategory(Category category) async {
    return await categoryCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    return await categoryCollection.doc(id).delete();
  }

  Stream<List<Category>> getCategories() {
    return categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromMap(doc)).toList();
    });
  }
}

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get productsCollection =>
      _firestore.collection('products');

  CollectionReference getVendorProducts(String vendorId) =>
      _firestore.collection('vendors').doc(vendorId).collection('vendor_products');

  Future<DocumentReference> addProduct(Product product) async {
    return await productsCollection.add(product.toMap());
  }

  Future<Product?> findProductByNameAndCategory(String name, String categoryId) async {
    final snapshot = await productsCollection
        .where('name', isEqualTo: name)
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Product.fromMap(snapshot.docs.first);
    }
    return null;
  }

  Future<void> addVendorProduct({
    required String vendorId,
    required String productId,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
    String? description,
  }) async {
    await getVendorProducts(vendorId).add({
      'productId': productId,
      'price': price,
      'quantity': quantity,
      'isAvailable': isAvailable,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (description != null) 'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateVendorProduct({
    required String vendorId,
    required String vendorProductId,
    required Map<String, dynamic> updatedData,
  }) async {
    await getVendorProducts(vendorId).doc(vendorProductId).update(updatedData);
  }

  Future<void> deleteVendorProduct({
    required String vendorId,
    required String vendorProductId,
  }) async {
    await getVendorProducts(vendorId).doc(vendorProductId).delete();
  }

  Stream<List<Map<String, dynamic>>> getVendorProductsStream(String vendorId) {
    return getVendorProducts(vendorId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    });
  }

  Stream<List<Product>> getProducts() {
  return productsCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Product.fromMap(doc)).toList();
  });
}


  Future<String> uploadProductImage(File imageFile, String vendorId, String productId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images/$vendorId/$productId.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload product image: $e");
    }
  }
}
