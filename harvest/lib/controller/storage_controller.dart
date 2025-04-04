import 'dart:io';

import 'package:harvest/controller/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

class StorageController {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }

  Future<String?> pickAndUploadImage(String userId) async {
    final XFile? pickedFile = await pickImage();

    if (pickedFile == null) return null;

    File imageFile = File(pickedFile.path);
    return await _storageService.uploadProfilePicture(imageFile, userId);
  }
}
