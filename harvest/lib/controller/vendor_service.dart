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

  Stream<List<Vendor>> populate(List<String> vendorIds) {
    if (vendorIds.isEmpty) {
      return Stream.value([]);
    }

    if (vendorIds.length > 10) {
      vendorIds = vendorIds.sublist(0, 10);
    }

    return vendorCollection
        .where(FieldPath.documentId, whereIn: vendorIds)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) =>Vendor.fromMap(doc)).toList())
        .asBroadcastStream();
  }

  Stream<List<String>> getVendorIds() {
    return vendorCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.id;
      }).toList();
    });
  }

  Stream<List<Vendor>> getVendors() {
    return vendorCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vendor.fromMap(doc);
      }).toList();
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

// global product collection
class ProductService {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<DocumentReference> addProduct(Product product) async {
    return await productsCollection.add(product.toMap());
  }

  Future<Product?> findProductByNameAndCategory(
      String name, String categoryId) async {
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

  Stream<List<Product>> getAllGlobalProducts() {
    return productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc)).toList();
    });
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> updatedData) async {
    return await productsCollection.doc(productId).update(updatedData);
  }

  Future<void> addVendorToProduct(String productId, String vendorId) async {
    await productsCollection.doc(productId).update({
      'vendorIds':
          FieldValue.arrayUnion([vendorId]), //duplicates vendor ids not added
    });
  }

  Future<void> removeVendorFromList(String productId, String vendorId) async {
    await productsCollection.doc(productId).update({
      'vendorIds': FieldValue.arrayRemove([vendorId]),
    });
  }

  Future<List<String>> getVendorIdsByProductInfo({
    String? productName,
    String? categoryId,
  }) async {
    Query query = productsCollection;
    if (productName != null && productName.isNotEmpty) {
      query = query.where('name', isEqualTo: productName);
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query
        .limit(5)
        .get(); // for search functionality, remove this limit 5 later
    final Set<String> allVendorIds = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final vendorIds = List<String>.from(data['vendorIds'] ?? []);
      allVendorIds.addAll(vendorIds);
    }
    return allVendorIds.toList();
  }
}

//moved "vendor_products" collection to global collection
class VendorProductController {
  final CollectionReference _vendorProductCollection =
      FirebaseFirestore.instance.collection('vendor_products');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  Future<void> addVendorProduct(VendorProduct product) async {
    await _vendorProductCollection.add(product.toMap());
  }

  Future<void> updateVendorProduct(VendorProduct vendorProduct) async {
    return await _vendorProductCollection
        .doc(vendorProduct.id)
        .update(vendorProduct.toMap());
  }

  Future<void> deleteVendorProduct(String vendorId, String productId) async {
    final query = await _vendorProductCollection
        .where('vendorId', isEqualTo: vendorId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      await _vendorProductCollection.doc(query.docs.first.id).delete();
    }
  }

  Stream<List<VendorProduct>> streamVendorProducts(String vendorId) {
    // vendor specific products
    return _vendorProductCollection
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => VendorProduct.fromMap(doc)).toList());
  }

  Future<List<VendorProduct>> getAllVendorProducts(String userId) async {
    final userDoc = await _usersCollection.doc(userId).get();
    final userData = userDoc.data();
    if (!userDoc.exists || userDoc.data() == null || !(userData is Map<String, dynamic> && userData.containsKey('shops'))) {
      // User doesn't exist, or doesn't have the 'shops' field, or is not a vendor.
      final query = await _vendorProductCollection.get();
      return query.docs.map((doc) => VendorProduct.fromMap(doc)).toList(); // Return all products
    }
    final List<String> vendorIdsToExclude = List<String>.from((userData)['shops'] ?? []);

    final query = await _vendorProductCollection.where('vendorId', whereNotIn: vendorIdsToExclude).get();

    return query.docs.map((doc) => VendorProduct.fromMap(doc)).toList();
  }

  Future<VendorProduct?> getVendorProductByProductId(String productId) async {
    final query = await _vendorProductCollection
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final product = VendorProduct.fromMap(doc);
      print("Loaded product: ${product.productName}, doc ID: ${product.id}");
      return product;
    }

    return null;
  }


  Future<List<VendorProduct>> getProductsByVendorAndCategory(
      String vendorId, String categoryId) async {
    // for vendor homepage
    final query = await _vendorProductCollection
        .where('vendorId', isEqualTo: vendorId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return query.docs.map((doc) => VendorProduct.fromMap(doc)).toList();
  }

  Future<List<VendorProduct>> getVendorAllProduct(String vendorId) async {
    final query = await _vendorProductCollection
        .where('vendorId', isEqualTo: vendorId)
        .get();
    return query.docs.map((doc) => VendorProduct.fromMap(doc)).toList();
  }

  // get all products for multiple vendors
  Future<List<VendorProduct>> getProductsFromVendors(
      List<String> vendorIds) async {
    if (vendorIds.isEmpty) return [];
    final query = await _vendorProductCollection
        .where('vendorId', whereIn: vendorIds)
        .get();
    return query.docs.map((doc) => VendorProduct.fromMap(doc)).toList();
  }

  Future<String> uploadProductImage(
      File imageFile, String vendorId, String productId) async {
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
