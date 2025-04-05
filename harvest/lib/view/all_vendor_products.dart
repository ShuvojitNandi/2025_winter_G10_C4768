import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/vendor_service.dart';
import '../controller/review_controller.dart';
import '../model/vendor_model.dart';
import '../model/product_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllVendorProductsPage extends StatefulWidget {
  final String userId;
  final String userName;

  const AllVendorProductsPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AllVendorProductsPage> createState() => _AllVendorProductsPageState();
}

class _AllVendorProductsPageState extends State<AllVendorProductsPage> {
  final VendorProductController _vendorProductController = VendorProductController();
  final VendorService _vendorService = VendorService();
  final ReviewController _reviewController = ReviewController();
  Map<String, List<VendorProduct>> _groupedProducts = {};
  Map<String, Vendor> _vendorDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  
  Future<void> _fetchProducts() async {
    final products = await _vendorProductController.getAllVendorProducts();
    final Map<String, List<VendorProduct>> grouped = {};

    for (var product in products) {
      grouped.putIfAbsent(product.vendorId, () => []).add(product);
    }

    
    final vendors = <MapEntry<String, Vendor>>[];
    for (var id in grouped.keys) {
      final vendor = await _vendorService.getVendor(id).first;
      if (vendor != null) vendors.add(MapEntry(id, vendor));
    }

    if (mounted) {
      setState(() {
        _groupedProducts = grouped;
        _vendorDetails = Map.fromEntries(vendors);
      });
    }
  }

  
  void _showReviewDialog(BuildContext context, VendorProduct product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: _ReviewDialogContent(
          product: product,
          userId: widget.userId,
          userName: widget.userName,
          vendorName: _vendorDetails[product.vendorId]?.vendor_name ?? 'Vendor',
          reviewController: _reviewController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("All Vendor Products"),
      ),
      body: _groupedProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _groupedProducts.entries.map((entry) {
                final vendor = _vendorDetails[entry.key];
                final products = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor?.vendor_name ?? 'Vendor',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(thickness: 2),
                      ...products.map((product) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    (product.imageUrl != null && product.imageUrl!.trim().isNotEmpty)
                                        ? product.imageUrl!
                                        : 'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 50,
                                        height: 50,
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
                                const SizedBox(width: 10),
                                Expanded(child: Text(product.productName, style: const TextStyle(fontSize: 16))),
                                ElevatedButton(
                                  onPressed: () => _showReviewDialog(context, product),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Rate this"),
                                ),
                              ],
                            ),
                          ))
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _ReviewDialogContent extends StatefulWidget {
  final VendorProduct product;
  final String userId;
  final String userName;
  final String vendorName;
  final ReviewController reviewController;

  const _ReviewDialogContent({
    required this.product,
    required this.userId,
    required this.userName,
    required this.vendorName,
    required this.reviewController,
  });

  @override
  State<_ReviewDialogContent> createState() => _ReviewDialogContentState();
}

class _ReviewDialogContentState extends State<_ReviewDialogContent> {
  final TextEditingController _descController = TextEditingController();
  int _rating = 3;
  File? _image;
  bool _uploading = false;

  final ImagePicker _picker = ImagePicker();
  final String _defaultImage = 'https://cdn0.iconfinder.com/data/icons/remoji-soft-1/512/emoji-thumbs-up-smile.png';

  
  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _image = File(file.path));
  }

 
  Future<void> _submitReview() async {
    setState(() => _uploading = true);
    final reviewId = DateTime.now().millisecondsSinceEpoch.toString();
    String? imageUrl;

    if (_image != null) {
      imageUrl = await widget.reviewController.uploadReviewImage(_image!, reviewId);
    }

    final review = Review(
      reviewId: reviewId,
      vendorProductId: widget.product.id!,  
      vendorId: widget.product.vendorId,
      userId: widget.userId,
      userName: widget.userName,
      comment: _descController.text.trim(),
      rating: _rating.toDouble(),
      imageUrl: imageUrl,
      timestamp: Timestamp.now(),
    );

    await widget.reviewController.addReview(review);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted to ${widget.vendorName}')),
      );
    }

    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _image != null
                      ? Image.file(_image!, width: double.infinity, height: 200, fit: BoxFit.cover)
                      : Image.network(
                          _defaultImage,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                          },
                        ),
                ),
                if (_image != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _image = null),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.product.productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Write your review'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Upload Image"),
            ),
            const SizedBox(height: 8),
            _uploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitReview,
                    child: const Text("Submit Review"),
                  )
          ],
        ),
      ),
    );
  }
}
