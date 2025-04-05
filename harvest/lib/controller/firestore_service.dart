import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final ref = storage
          .ref()
          .child('profilePictures')
          .child('$userId-${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      
      return '';  
    }
  }
}
