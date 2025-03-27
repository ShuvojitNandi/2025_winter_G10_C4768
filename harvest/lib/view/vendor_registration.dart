import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harvest/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import '../model/vendor_model.dart';
import '../controller/vendor_service.dart';
import '../controller/user_controller.dart';
import '../view/vendor_home.dart';

class VendorRegistrationPage extends StatefulWidget {
  @override
  _VendorRegistrationPageState createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _vendorNameController = TextEditingController();
  final _storeDescripController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  List<String> _owners = [];
  List<String> _confDates = [];
  final _ownerEmailController = TextEditingController();

  String? _storeImageUrl; // To store the store image URL
  final _vendorService = VendorService();
  final _userService = UserController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _vendorNameController.dispose();
    _storeDescripController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadStoreImage() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String downloadUrl = await _vendorService.uploadStoreImage(
            imageFile, FirebaseAuth.instance.currentUser!.uid);
        setState(() {
          _storeImageUrl = downloadUrl; // Store the URL after upload
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
  }

  Future<void> _selectConferenceDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _confDates.add("${pickedDate.toLocal()}".split(' ')[0]);
      });
    }
  }

  Future<void> _addOwnerEmail() async {
    final ownerEmail = _ownerEmailController.text;
    if (ownerEmail.isNotEmpty) {
      try {
        // Fetch the user data by email
        UserModel? user = await _userService.fetchUserDataByEmail(ownerEmail);
        if (user != null && user.uid != null) {
          setState(() {
            _owners.add(user.uid!); // Add owner ID to the list if uid is not null
          });
          _ownerEmailController.clear(); // Clear the owner email field after adding
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('No user found with that email address or UID is null')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error adding owner: $e')));
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _storeImageUrl != null) {
      final vendor = Vendor(
        vendor_name: _vendorNameController.text,
        store_img: _storeImageUrl!,
        store_descrip: _storeDescripController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        owners: [..._owners, FirebaseAuth.instance.currentUser!.uid], // Add the current user's UID to the owners list
        conf_dates: _confDates,
      );

      try {
        // Register vendor in the 'vendors' collection
        final vendorDocRef = await _vendorService.addVendor(vendor);
        final vendorId = vendorDocRef.id;

        // Pop the registration page and return the vendorId to the homepage
        Navigator.pop(context, vendorId);  // This will return vendorId back to the homepage

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error registering vendor: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Please fill all required fields and upload a store image.')));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vendor Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickAndUploadStoreImage,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        _storeImageUrl != null && _storeImageUrl!.isNotEmpty
                            ? NetworkImage(_storeImageUrl!)
                            : null,
                    child: _storeImageUrl == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vendorNameController,
                  decoration: InputDecoration(labelText: 'Vendor Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vendor name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _storeDescripController,
                  decoration: InputDecoration(labelText: 'Store Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter store description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerEmailController,
                  decoration: InputDecoration(labelText: 'Owner Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter owner email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addOwnerEmail,
                  child: Text('Add Multilple Owner')
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectConferenceDate,
                  child: Text('Pick Conference Date'),
                ),
                Wrap(
                  children: _confDates
                      .map((date) => Chip(label: Text(date)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Register Vendor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
