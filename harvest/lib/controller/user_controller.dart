import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;


  
  // GET user data by UNIQUE
  Future<UserModel?> fetchUserDataByEmail(String email) async {
    if (email.isEmpty) return null;

    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(userSnapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user data: $e");   //TESTING . delete later
    }
    return null;
  }


  Future<bool> updateUser(UserModel user) async {
    try {
      if (user.uid!.isEmpty) return false;

      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }


  // new shop to the user's list of ships
  Future<void> addShop(String shopId) async {
    if (currentUserId == null) return;
    await _firestore.collection('users').doc(currentUserId).update({
      'shops': FieldValue.arrayUnion([shopId]),
    });
  }


  
  Future<void> addUser(String uid, String name, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid':uid,
        'name': name,
        'email': email,
        'profileImageUrl': '', 
        'createdAt': FieldValue.serverTimestamp(),
        'shops': [],
      });
    } catch (e) {
      throw Exception("Error adding user to Firestore: $e");
    }
  }
}
