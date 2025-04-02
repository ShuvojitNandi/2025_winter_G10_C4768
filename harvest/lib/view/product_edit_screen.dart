import 'package:flutter/material.dart';
import '../model/vendor_model.dart';
import '../controller/vendor_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class updateProduct extends StatefulWidget {
  final VendorProduct? vendorProduct;
  const updateProduct ({super.key, this.vendorProduct});
  @override
  _updateProductState createState() => _updateProductState();
}

class _updateProductState extends State<updateProduct> {
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  final _vendorProduct = VendorProductController();
  final ImagePicker _picker = ImagePicker();

  String? _uploadedImageUrl;
  late bool _available;
  static const String _defaultImageUrl = 'https://sjfm.ca/wp-content/uploads/2018/07/FarmersMarketLauchLogo.jpg';

  @override
  void initState() {
    super.initState();
    if(widget.vendorProduct != null) {
      _productNameController.text = widget.vendorProduct!.productName;
      _productPriceController.text = widget.vendorProduct!.price.toString();
      _productDescriptionController.text = widget.vendorProduct!.description ?? "";
      _productQuantityController.text = widget.vendorProduct!.quantity.toString();
      _uploadedImageUrl = widget.vendorProduct!.imageUrl ?? "";
      _available = widget.vendorProduct!.isAvailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Vendor product Edit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Change the Product info:'),
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _productQuantityController,
                decoration: InputDecoration(labelText: 'Product Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _productDescriptionController,
                decoration: InputDecoration(labelText: 'Product Description (optional)'),
              ),
              SizedBox(height: 10),
              Text("Choose Availability:"),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _available,
                    onChanged: (newValue) {
                      setState(() {
                        _available = newValue;
                      });
                    },
                  ),
                  SizedBox(width: 50),
                  Text(_available ? 'In Stock' : 'Out of Stock'),
                  SizedBox(width: 8),
                  Icon(
                    _available ? Icons.check_circle : Icons.cancel,
                    color: _available ? Colors.green : Colors.red,
                  ),

                ],
              ),
              const SizedBox(height: 10),
              _buildSectionTitle('Product Image'),
              ElevatedButton.icon(
                onPressed: _pickAndUploadImage,
                icon: Icon(Icons.upload),
                label: Text('Upload Product Image'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(
                      _uploadedImageUrl ?? _defaultImageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (_uploadedImageUrl != null)
                      GestureDetector(
                        onTap: () {
                          setState(() => _uploadedImageUrl = null);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Image removed')),
                          );
                        },
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text('update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final productId = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        final url = await _vendorProduct.uploadProductImage(file, widget.vendorProduct!.vendorId, productId);
        setState(() => _uploadedImageUrl = url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      }
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _updateProduct() async {
    final name = _capitalize(_productNameController.text.trim());
    final price = double.tryParse(_productPriceController.text.trim()) ?? 0;
    final quantity = int.tryParse(_productQuantityController.text.trim()) ?? 0;
    final description = _productDescriptionController.text.trim();


    final vendorProduct = VendorProduct(
      id : widget.vendorProduct!.id,
      vendorId: widget.vendorProduct!.vendorId,
      productId: widget.vendorProduct!.productId,
      productName: name,
      categoryId: widget.vendorProduct!.categoryId,
      price: price,
      quantity: quantity,
      isAvailable: _available,
      imageUrl: _uploadedImageUrl,
      description: description.isNotEmpty ? description : null,
    );
    await _vendorProduct.updateVendorProduct(vendorProduct);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name has been updated')),
      );
      Navigator.pop(context);
    }
  }
}