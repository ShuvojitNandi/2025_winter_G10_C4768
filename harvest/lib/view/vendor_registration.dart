import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_model.dart';
import '../model/vendor_model.dart';
import '../controller/vendor_service.dart';
import '../controller/user_controller.dart';

class VendorRegistrationPage extends StatefulWidget {
  final Vendor? vendor;

  const VendorRegistrationPage({super.key, this.vendor});

  @override
  State<VendorRegistrationPage> createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _vendorNameController = TextEditingController();
  final _storeDescripController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _ownerEmailController = TextEditingController();

  final List<String> _owners = [];
  final List<String> _confDates = [];
  final Map<String, String> _ownerEmails = {};

  String? _storeImageUrl;
  final _vendorService = VendorService();
  final _userService = UserController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.vendor != null) {
      _vendorNameController.text = widget.vendor!.vendor_name;
      _storeDescripController.text = widget.vendor!.store_descrip;
      _emailController.text = widget.vendor!.email;
      _phoneController.text = widget.vendor!.phone;
      _websiteController.text = widget.vendor!.website ?? '';
      _facebookController.text = widget.vendor!.facebook ?? '';
      _instagramController.text = widget.vendor!.instagram ?? '';
      _storeImageUrl = widget.vendor!.store_img;
      _owners.addAll(widget.vendor!.owners);
      _confDates.addAll(widget.vendor!.conf_dates);
      _resolveOwnerEmails();
    }
  }

  Future<void> _resolveOwnerEmails() async {
    for (String uid in _owners) {
      final email = await _userService.getEmailByUid(uid);
      if (email != null) {
        setState(() {
          _ownerEmails[uid] = email;
        });
      }
    }
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _storeDescripController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadStoreImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String downloadUrl = await _vendorService.uploadStoreImage(
          imageFile,
          FirebaseAuth.instance.currentUser!.uid,
        );
        setState(() {
          _storeImageUrl = downloadUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
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
        UserModel? user = await _userService.fetchUserDataByEmail(ownerEmail);
        if (user != null && user.uid != null) {
          setState(() {
            _owners.add(user.uid!);
            _ownerEmails[user.uid!] = ownerEmail;
          });
          _ownerEmailController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found with that email address.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding owner: $e')));
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final vendor = Vendor(
        id: widget.vendor?.id,
        vendor_name: _vendorNameController.text,
        store_img: _storeImageUrl ?? '',
        store_descrip: _storeDescripController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        owners: widget.vendor == null
            ? [..._owners, FirebaseAuth.instance.currentUser!.uid]
            : _owners,
        conf_dates: _confDates,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        facebook: _facebookController.text.isNotEmpty ? _facebookController.text : null,
        instagram: _instagramController.text.isNotEmpty ? _instagramController.text : null,
      );

      try {
        if (widget.vendor == null) {
          final vendorDocRef = await _vendorService.addVendor(vendor);
          Navigator.pop(context, vendorDocRef.id);
        } else {
          await _vendorService.updateVendor(vendor);
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving vendor: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.lightGreen,
        title: Text(widget.vendor == null ? 'Register Vendor' : 'Update Vendor'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickAndUploadStoreImage,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: _storeImageUrl != null && _storeImageUrl!.isNotEmpty
                        ? NetworkImage(_storeImageUrl!)
                        : null,
                    child: _storeImageUrl == null || _storeImageUrl!.isEmpty
                        ? Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
                if (_storeImageUrl != null && _storeImageUrl!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _storeImageUrl = '';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Store image removed.')),
                      );
                    },
                    icon: Icon(Icons.delete, color: Colors.black),
                    label: Text("Remove Image", style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vendorNameController,
                  decoration: InputDecoration(labelText: 'Vendor Name'),
                  validator: (value) => value!.isEmpty ? 'Enter vendor name' : null,
                ),
                TextFormField(
                  controller: _storeDescripController,
                  decoration: InputDecoration(labelText: 'Store Description'),
                  validator: (value) => value!.isEmpty ? 'Enter store description' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Enter email' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) => value!.isEmpty ? 'Enter phone' : null,
                ),
                TextFormField(
                  controller: _websiteController,
                  decoration: InputDecoration(labelText: 'Website (optional)'),
                ),
                TextFormField(
                  controller: _facebookController,
                  decoration: InputDecoration(labelText: 'Facebook (optional)'),
                ),
                TextFormField(
                  controller: _instagramController,
                  decoration: InputDecoration(labelText: 'Instagram (optional)'),
                ),
                const SizedBox(height: 16),
                if (_ownerEmails.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: _ownerEmails.entries
                        .map((entry) => Chip(label: Text(entry.value)))
                        .toList(),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerEmailController,
                  decoration: InputDecoration(labelText: 'Owner Email'),
                ),
                ElevatedButton(
                  onPressed: _addOwnerEmail,
                  child: Text('Add Additional Owner'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _selectConferenceDate,
                  child: Text('Pick Conference Date'),
                ),
                Wrap(
                  children: _confDates.map((date) => Chip(label: Text(date))).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.vendor == null ? 'Register Vendor' : 'Update Vendor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
