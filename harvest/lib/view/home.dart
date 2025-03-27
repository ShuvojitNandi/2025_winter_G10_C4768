// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harvest/controller/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import '../model/vendor_model.dart';
import '../controller/vendor_service.dart';
import '../controller/user_controller.dart';
import '../view/vendor_home.dart';
import 'vendor_registration.dart';

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
  final VendorService _vendorService =
      VendorService(); // For fetching vendor info

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

  // Build vendor tile using Container widgets
  Widget _buildVendorTile(String vendorId) {
    return StreamBuilder<Vendor?>(
      stream: _vendorService.getVendor(vendorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No vendor found'));
        }
        Vendor vendor = snapshot.data!;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorHomePage(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Container for the store image
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: vendor.store_img.isNotEmpty
                          ? NetworkImage(vendor.store_img)
                          : AssetImage('assets/placeholder_image.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: vendor.store_img.isEmpty
                      ? Center(child: Icon(Icons.store, size: 50, color: Colors.white))
                      : null,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    vendor.vendor_name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 168, 144, 209), // Deep purple app bar
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
                    Text(userName ?? 'User',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.currentUser?.email ?? 'user@example.com',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 70),
            Text("Your Shops:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: userShops.isEmpty
                  ? Center(child: Text("No shops added yet"))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: userShops.length,
                      itemBuilder: (context, index) {
                        return _buildVendorTile(userShops[index]);
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () async {
                final vendorId = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => VendorRegistrationPage()),
                );
                if (vendorId != null && vendorId.isNotEmpty) {
                  await _userController.addShopToUser(widget.currentUser!.uid, vendorId);
                  _fetchUserData();
                }
              },
              child: Text("Register as Vendor"),
            ),
          ],
        ),
      ),
    );
  }
}
