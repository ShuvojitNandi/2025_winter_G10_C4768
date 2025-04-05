import 'dart:io';
import 'package:flutter/material.dart';
import 'package:harvest/controller/vendor_service.dart';
import '../controller/review_controller.dart';
import '../model/product_review.dart';
import '../model/vendor_model.dart';
import './adding_category_product.dart';

class VendorReviewPage extends StatefulWidget {
  final String vendorId;
  const VendorReviewPage({super.key, required this.vendorId});

  @override
  State<VendorReviewPage> createState() => _VendorReviewPageState();
}

class _VendorReviewPageState extends State<VendorReviewPage> {
  String? _selectedCategoryId;
  List<VendorProduct> _vendorProducts = [];

  final ReviewController _reviewController = ReviewController();
  final CategoryService _categoryService = CategoryService();
  static const String _defaultImageUrl = 'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740';

  Future<List<Review>> _getReviewsForProduct(String productId) async {
    return await _reviewController.getReviewsByProductId(productId);
  }

  Future<void> _fetchProducts(String categoryId) async {
    final products = await VendorProductController().getProductsByVendorAndCategory(widget.vendorId, categoryId);
    setState(() {
      _vendorProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<Category>>(
            stream: _categoryService.getCategories(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final categories = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                    if (value != null) {
                      _fetchProducts(value);
                    }
                  },
                  decoration: InputDecoration(labelText: 'Select Category'),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: _selectedCategoryId == null
                ? Center(child: Text('Select a category to view products.'))
                : _vendorProducts.isEmpty
                    ? Center(child: Text('No products in this category.'))
                    : ListView.builder(
                        itemCount: _vendorProducts.length,
                        itemBuilder: (context, index) {
                          final product = _vendorProducts[index];
                          return FutureBuilder<List<Review>>(
                            future: _getReviewsForProduct(product.id!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No reviews for this product.'));
                              }

                              final reviews = snapshot.data!;
                              final averageRating = reviews.fold(0.0, (sum, review) => sum + review.rating) / reviews.length;

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              product.imageUrl != null && product.imageUrl!.isNotEmpty
                                                  ? product.imageUrl!
                                                  : _defaultImageUrl,
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  alignment: Alignment.center,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(product.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text('Avg. Rating: ${averageRating.toStringAsFixed(1)}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      ...reviews.map((review) => Column(
                                        children: [
                                          Divider(),
                                          Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(review.comment),
                                          Text('Rating: ${review.rating}'),
                                          if (review.imageUrl != null)
                                            Image.network(review.imageUrl!),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
