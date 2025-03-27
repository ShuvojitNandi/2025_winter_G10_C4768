import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/vendor_model.dart';

class VendorService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference vendorCollection;

  VendorService()
      : vendorCollection = FirebaseFirestore.instance.collection('vendors');

  // Add a new vendor (includes their store data)
  Future<DocumentReference<Object?>> addVendor(Vendor vendor) async {
    return await vendorCollection.add(vendor.toMap());
  }

  // Update an existing vendor's data
  Future<void> updateVendor(Vendor vendor) async {
    return await vendorCollection.doc(vendor.id).update(vendor.toMap());
  }

  // Delete a vendor
  Future<void> deleteVendor(String id) async {
    return await vendorCollection.doc(id).delete();
  }

  // Stream to get a specific vendor by ID
  Stream<Vendor?> getVendor(String vendorId) {
    return vendorCollection.doc(vendorId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return Vendor.fromMap(doc);
    });
  }

  // Upload store image for a vendor
  Future<String> uploadStoreImage(File imageFile, String vendorId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('store_images/$vendorId');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload store image: $e");
    }
  }
}

class CategoryService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference categoryCollection;

  CategoryService()
      : categoryCollection = FirebaseFirestore.instance.collection('categories');

  // Add a new category
  Future<DocumentReference<Object?>> addCategory(Category category) async {
    return await categoryCollection.add(category.toMap());
  }

  // Update an existing category
  Future<void> updateCategory(Category category) async {
    return await categoryCollection.doc(category.id).update(category.toMap());
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    return await categoryCollection.doc(id).delete();
  }

  // Stream to get all categories
  Stream<List<Category>> getCategories() {
    return categoryCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      } else {
        List<Category> categories =
            snapshot.docs.map((doc) => Category.fromMap(doc)).toList();
        return categories;
      }
    });
  }
}

class ProductService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference productCollection;

  ProductService()
      : productCollection = FirebaseFirestore.instance.collection('products');

  // Add a new product
  Future<DocumentReference<Object?>> addProduct(Product product) async {
    return await productCollection.add(product.toMap());
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    return await productCollection.doc(product.id).update(product.toMap());
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    return await productCollection.doc(id).delete();
  }

  // Stream to get all products
  Stream<List<Product>> getProducts() {
    return productCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      } else {
        List<Product> products =
            snapshot.docs.map((doc) => Product.fromMap(doc)).toList();
        return products;
      }
    });
  }
}
