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
  final _globalProduct = ProductService();
  final _vendorProduct = VendorProductController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategoryId;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  String _selectedUnit = 'Kg';

  static const String _defaultImageUrl = 'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740';

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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category "$name" added successfully')));
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
              SizedBox(height: 10),
              Text("Select Unit:", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Kg', 'lb', 'L'].map((unit) {
                  final isSelected = _selectedUnit == unit;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ChoiceChip(
                      label: Text(unit),
                      selected: isSelected,
                      selectedColor: Colors.purple.shade300,
                      onSelected: (_) {
                        setState(() => _selectedUnit = unit);
                      },
                    ),
                  );
                }).toList(),
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
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isUploadingImage
                          ? Center(child: CircularProgressIndicator())
                          : Image.network(
                              _uploadedImageUrl?.isNotEmpty == true ? _uploadedImageUrl! : _defaultImageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty && !_isUploadingImage)
                      GestureDetector(
                        onTap: () {
                          setState(() => _uploadedImageUrl = null);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image removed')));
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
      setState(() => _isUploadingImage = true);
      final file = File(pickedFile.path);
      final productId = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        final url = await _vendorProduct.uploadProductImage(file, widget.vendorId, productId);
        setState(() => _uploadedImageUrl = url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      } finally {
        setState(() => _isUploadingImage = false);
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

    final existingProduct = await _globalProduct.findProductByNameAndCategory(name, categoryId);
    String productId;

    if (existingProduct != null) {
      productId = existingProduct.id!;
    } else {
      final product = Product(name: name, categoryId: categoryId);
      final docRef = await _globalProduct.addProduct(product);
      productId = docRef.id;
    }

    final vendorProduct = VendorProduct(
      vendorId: widget.vendorId,
      productId: productId,
      productName: name,
      categoryId: categoryId,
      price: price,
      quantity: quantity,
      unit: _selectedUnit,
      isAvailable: true,
      imageUrl: _uploadedImageUrl,
      description: description.isNotEmpty ? description : null,
    );

    await _vendorProduct.addVendorProduct(vendorProduct);
    await _globalProduct.addVendorToProduct(productId, widget.vendorId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name has been added to your store')));
      Navigator.pop(context);
    }
  }
}
