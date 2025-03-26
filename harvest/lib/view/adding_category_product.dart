import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/vendor_model.dart';
import '../controllers/vendor_service.dart';
class CategoryProductManager extends StatefulWidget {
  @override
  _CategoryProductManagerState createState() => _CategoryProductManagerState();

}

class _CategoryProductManagerState extends State<CategoryProductManager> {
  final _categoryNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productImageController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  final _categoryService = CategoryService();
  final _productService = ProductService();

  String? _selectedCategoryId;

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
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_categoryNameController.text.isNotEmpty) {
                    final category = Category(name: _categoryNameController.text);
                    await _categoryService.addCategory(category);
                    _categoryNameController.clear();
                    setState(() { }); // refresh categories
                  }
                },
                child: Text('Add Category'),
              ),
              SizedBox(height: 20),
              StreamBuilder<List<Category>>(
                stream: _categoryService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final categories = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Select Category'),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedCategoryId != null &&
                  _productNameController.text.isNotEmpty) {
                    final product = Product(
                      name: _productNameController.text,
                      categoryId: _selectedCategoryId!,
                      price: double.tryParse(_productPriceController.text) ?? 0.0,
                    );
                    await _productService.addProducts(product);
                    _productNameController.clear();
                    _productPriceController.clear();

                  }
                },
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}