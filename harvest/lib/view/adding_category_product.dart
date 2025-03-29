import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/vendor_model.dart';
import '../controller/vendor_service.dart';

class CategoryProductManager extends StatefulWidget {
  final String vendorId;
  const CategoryProductManager({super.key, required this.vendorId});

  @override
  _CategoryProductManagerState createState() => _CategoryProductManagerState();
}

class _CategoryProductManagerState extends State<CategoryProductManager> {
  final _categoryNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  final _categoryService = CategoryService();
  final _productService = ProductService();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategoryId;
  String? _uploadedImageUrl;

  static const String _defaultImageUrl = 'https://sjfm.ca/wp-content/uploads/2018/07/FarmersMarketLauchLogo.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category & Product Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Create or Select Category'),
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _capitalize(_categoryNameController.text.trim());
                    if (name.isNotEmpty) {
                      final category = Category(name: name);
                      final result = await _categoryService.addCategory(category);

                      if (result is String) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Category "$name" added successfully')),
                        );
                      }

                      _categoryNameController.clear();
                      setState(() {});
                    }
                  },
                  child: Text('Add Category'),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<Category>>(
                stream: _categoryService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final categories = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                      },
                      decoration: InputDecoration(labelText: 'Select Category'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Add Product Details'),
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
                onPressed: _addProduct,
                child: Text('Add Product'),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final productId = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        final url = await _productService.uploadProductImage(file, widget.vendorId, productId);
        setState(() => _uploadedImageUrl = url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      }
    }
  }

  Future<void> _addProduct() async {
    final name = _capitalize(_productNameController.text.trim());
    final categoryId = _selectedCategoryId;
    final price = double.tryParse(_productPriceController.text.trim()) ?? 0;
    final quantity = int.tryParse(_productQuantityController.text.trim()) ?? 0;
    final description = _productDescriptionController.text.trim();

    if (categoryId == null || name.isEmpty) return;

    final existingProduct = await _productService.findProductByNameAndCategory(name, categoryId);
    String productId;

    if (existingProduct != null) {
      productId = existingProduct.id!;
    } else {
      final product = Product(name: name, categoryId: categoryId);
      final docRef = await _productService.addProduct(product);
      productId = docRef.id;
    }

    await _productService.addVendorProduct(
      vendorId: widget.vendorId,
      productId: productId,
      price: price,
      quantity: quantity,
      isAvailable: true,
      imageUrl: _uploadedImageUrl,
      description: description.isNotEmpty ? description : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name has been added to your store')),
      );
      Navigator.pop(context);
    }
  }
}
