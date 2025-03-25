import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/vendor_model.dart';

class VendorService{
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference vendorCollection;
  VendorService()
        : vendorCollection = FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('vendor');

  Future<DocumentReference<Object?>> addVendor(Vendor vendor) async {
    return await vendorCollection.add(vendor.toMap());
  }

  Future<void> updateVendor(Vendor vendor) async {
    return await vendorCollection.doc(vendor.id).update(vendor.toMap());
  }

  Future<void> deleteVendor(String id) async{
    return await vendorCollection.doc(id).delete();
  }

  Stream<Vendor?> getVendor() {
    return vendorCollection.doc(user!.uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return Vendor.fromMap(doc);
    });
  }

}

class CategoryService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference categoryCollection;

  CategoryService()
          : categoryCollection = FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('categories');

  Future<DocumentReference<Object?>> addCategory(Category category) async {
    return await categoryCollection.add(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    return await categoryCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    return await categoryCollection.doc(id).delete();
  }

  Stream<List<Category>> getCategories() {
    return categoryCollection.snapshots().map( (snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }else{
         List<Category> categories = snapshot.docs.map((doc) => Category.fromMap(doc)).toList();
         return categories;
      }
    });
  }
}

class ProductService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference productCollection;

  ProductService()
      : productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('products');

  Future<DocumentReference<Object?>> addProducts(Product product) async {
    return await productCollection.add(product.toMap());
  }

  Future<void> updateProducts(Product product) async {
    return await productCollection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProducts(String id) async {
    return await productCollection.doc(id).delete();
  }

  Stream<List<Product>> getProducts() {
    return productCollection.snapshots().map( (snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }else{
        List<Product> products = snapshot.docs.map((doc) => Product.fromMap(doc)).toList();
        return products;
      }
    });
  }
}