import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/user_controller.dart';
import '../controller/firestore_service.dart';
import 'package:image_picker/image_picker.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.currentUser});
  final User? currentUser;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  String? profileImageUrl;
  String? userName;
  List<String> userShops = [];

  final UserController _userController = UserController();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }


  Future<void> _fetchUserData() async {
    if (widget.currentUser != null) {
      var user = await _userController.fetchUserDataByEmail(widget.currentUser!.email!);
      setState(() {
        userName = user?.name ?? widget.currentUser?.displayName;
        profileImageUrl = user?.profileImageUrl;
        userShops = user?.shops ?? [];
      });
    }
  }


  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String downloadUrl = await _storageService.uploadProfilePicture(imageFile, widget.currentUser!.uid);
      if (downloadUrl.isNotEmpty) {
        setState(() {
          profileImageUrl = downloadUrl;
        });

        await _userController.updateProfilePicture(widget.currentUser!.uid, downloadUrl);
      }
    }
  }


  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Upload Picture"),
                onPressed: () {
                  Navigator.pop(context);
                  _pickAndUploadImage();
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Delete Picture"),
                onPressed: () {
                  setState(() {
                    profileImageUrl = null;
                  });
                  _userController.updateProfilePicture(widget.currentUser!.uid, '');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Welcome ${userName ?? 'User'}"), 
        actions: [
          IconButton(onPressed: signout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _showProfileDialog,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.currentUser?.email ?? 'user@example.com', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Your Shops:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: userShops.isEmpty
                  ? Center(child: Text("No shops added yet"))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: userShops.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text(userShops[index])),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
