import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harvest/view/vendor_home.dart';
import '../model/vendor_model.dart';
import '../controllers/vendor_service.dart';

class VendorRegistrationPage extends StatefulWidget {
  @override
  _VendorRegistrationPageState createState() =>
    _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _vendorNameController = TextEditingController();
  final _storeImgController = TextEditingController();
  final _storeDescripController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  List<String> _owners = [];
  List<String> _confDates = [];
  final _ownerController = TextEditingController();
  final _confDateController = TextEditingController();

  final _vendorService = VendorService();
  final _storeService = StoreService();

  @override
  void dispose() {
    _vendorNameController.dispose();
    _storeImgController.dispose();
    _storeDescripController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _ownerController.dispose();
    _confDateController.dispose();
    super.dispose();
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
              controller: _storeImgController,
              decoration: InputDecoration(labelText: 'Store Image URL'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter store image URL';
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
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(labelText: 'Website (Optional)'),
            ),
            TextFormField(
              controller: _facebookController,
              decoration: InputDecoration(labelText: 'Facebook (Optional)'),
            ),
            TextFormField(
              controller: _instagramController,
              decoration: InputDecoration(labelText: 'Instagram (Optional)'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ownerController,
                    decoration: InputDecoration(labelText: 'Owner Name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_ownerController.text.isNotEmpty) {
                      setState(() {
                        _owners.add(_ownerController.text);
                        _ownerController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Wrap(
              children: _owners.map((owner) => Chip(label: Text(owner))).toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _confDateController,
                    decoration: InputDecoration(labelText: 'Conference Date'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_confDateController.text.isNotEmpty) {
                      setState(() {
                        _confDates.add(_confDateController.text);
                        _confDateController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Wrap(
              children: _confDates.map((date) => Chip(label: Text(date))).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final vendor = Vendor(
                    vendor_name: _vendorNameController.text,
                    store_img: _storeImgController.text,
                    store_descrip: _storeDescripController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    website: _websiteController.text,
                    facebook: _facebookController.text,
                    instagram: _instagramController.text,
                    owners: _owners,
                    conf_dates: _confDates,
                  );

                  try {
                    final vendorDocRef = await _vendorService.addVendor(vendor);
                    final vendorId = vendorDocRef.id;
                    final stores = Stores(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        vendorId: vendorId,
                    );
                    await _storeService.addStore(stores);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VendorHomePage()),
                    ); // Navigate back after successful registration
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error registering vendor: $e')),
                    );
                  }
                }
              },
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