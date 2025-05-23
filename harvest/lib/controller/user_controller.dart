import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<UserModel?> fetchUserDataByEmail(String email) async {
    if (email.isEmpty) return null;
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userSnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(
            userSnapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  Future<String?> getEmailByUid(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['email'] as String?;
      }
    } catch (e) {
      print("Error fetching email by UID: $e");
    }
    return null;
  }

  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      print("Error updating profile picture: $e");
    }
  }

  Future<void> addUser(String uid, String name, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'shops': [],
      });
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  Future<void> addShopToUser(String userId, String shopId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'shops': FieldValue.arrayUnion([shopId]),
      });
    } catch (e) {
      print("Error adding shop to user: $e");
    }
  }
}
