import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {
  final String? id;
  final String vendor_name;
  final String store_img;

  final String store_descrip;
  List<String> conf_dates;
  List<String> owners;
  final String email;
  final String phone;
  final String? website;
  final String? facebook;
  final String? instagram;


  Vendor({
    this.id,
    required this.vendor_name,
    required this.owners,
    required this.store_img,
    required this.store_descrip,
    required this.conf_dates,
    required this.email,
    required this.phone,
    this.website,
    this.facebook,
    this.instagram
  });

  Map<String, dynamic> toMap(){
    return{
      'vendor_name':vendor_name,
      'owners':owners,
      'store_img':store_img,
      'store_descrip':store_descrip,
      'conf_dates':conf_dates,
      'email': email,
      'phone': phone,
      if (website != null) 'website': website,
      if (facebook != null) 'facebook': facebook,
      if (instagram != null) 'instagram': instagram,
    };
  }

  static Vendor fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Vendor(
      id: doc.id,
      vendor_name: map['vendor_name'] ?? '',
      owners: List<String>.from(map['owners'] ?? []),
      store_img: map['store_img'] ?? '',
      store_descrip: map['store_descrip'] ?? '',
      conf_dates: List<String>.from(map['conf_dates'] ?? []),
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }


}

class Category {
  final String? id;
  final String name;

  Category({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return{
      'name': name,
    };
  }

  static Category fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: map['name'] ?? '',
    );
  }
}

class Product {
  final String? id;
  final String name;
  final String categoryId;
  
  Product({
    this.id,
    required this.name,
    required this.categoryId,
  
  });

  Map<String, dynamic> toMap() {
    return{
      'name': name,
      'categoryId': categoryId,
    };
  }

  static Product fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: map['name'] ?? '',
      categoryId: map['categoryId'] ?? '',
    );
  }
}
