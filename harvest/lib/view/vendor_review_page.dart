import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/review_controller.dart';
import '../controller/vendor_service.dart';
import '../model/vendor_model.dart';
import '../model/product_review.dart';

class VendorReviewPage extends StatefulWidget {
  final String vendorId;

  const VendorReviewPage({super.key, required this.vendorId});

  @override
  State<VendorReviewPage> createState() => _VendorReviewPageState();
}

class _VendorReviewPageState extends State<VendorReviewPage> {
  final ReviewController _reviewController = ReviewController();
  final VendorProductController _vendorProductController = VendorProductController();
  final CategoryService _categoryService = CategoryService();

  List<VendorProduct> _vendorProducts = [];
  String? _selectedCategoryId;


  static const String _defaultImageUrl =
      'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740';

  @override
  void initState() {
    super.initState();
    _fetchAllVendorProducts();
    _selectedCategoryId = 'all';
  }

  Future<void> _fetchAllVendorProducts() async {
    final products = await _vendorProductController.getVendorAllProduct(widget.vendorId);
    setState(() {
      _vendorProducts = products;
    });
  }

  Future<void> _fetchProducts(String categoryId) async {
    final products =
        await _vendorProductController.getProductsByVendorAndCategory(widget.vendorId, categoryId);
    setState(() {
      _vendorProducts = products;
    });
  }


  Future<List<Review>> _getReviewsForProduct(String productId) async {
    return _reviewController.getReviewsByProductId(productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              Expanded(
                child: _vendorProducts.isEmpty
                    ? const Center(child: Text('No products to show.'))
                    : _buildProductReviewsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return StreamBuilder<List<Category>>(
      stream: _categoryService.getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data!;

        final extendedCategories = [
          Category(id: 'all', name: 'All Product Reviews'),
          ...categories,
        ];

        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          items: extendedCategories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
            if (value == 'all') {
              _fetchAllVendorProducts();
            } else if (value != null) {
              _fetchProducts(value);
            }
          },
          decoration: const InputDecoration(labelText: 'Select Category'),
        );
      },
    );
  }

  Widget _buildProductReviewsList() {
    return ListView.builder(
      itemCount: _vendorProducts.length,
      itemBuilder: (context, index) {
        final product = _vendorProducts[index];
        return FutureBuilder<List<Review>>(
          future: _getReviewsForProduct(product.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const SizedBox.shrink();
            }
            final double avgRating =
                reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
            return _buildProductReviewsCard(product, avgRating, reviews);
          },
        );
      },
    );
  }


  Widget _buildProductReviewsCard(VendorProduct product, double avgRating, List<Review> reviews) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 30),
      color:Colors.grey.shade300,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                (product.imageUrl != null && product.imageUrl!.trim().isNotEmpty)
                    ? product.imageUrl!
                    : _defaultImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.productName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: reviews.map((review) => _buildSingleReviewCard(review)).toList(),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSingleReviewCard(Review review) {
    final DateTime dateTime = review.timestamp.toDate();
    final formattedDate = DateFormat("MMM dd, yyyy").format(dateTime);
    final String userInitial =
        review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[30],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green,
                radius: 18,
                child: Text(
                  userInitial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(formattedDate,
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.round() ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment),
          if (review.imageUrl != null && review.imageUrl!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                review.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
