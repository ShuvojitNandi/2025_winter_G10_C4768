import 'package:flutter/material.dart';
import 'package:harvest/controller/vendor_service.dart';
import 'package:harvest/model/vendor_model.dart';



class CustomerVendorPage extends StatefulWidget {
  final String vendorId;
  final String vendorName;

  const CustomerVendorPage({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<CustomerVendorPage> createState() => _CustomerVendorPageState();
}


class _CustomerVendorPageState extends State<CustomerVendorPage> {
  String? _selectedCategoryId;
  List<VendorProduct> _vendorProducts = [];

  final VendorProductController _vendorProductController = VendorProductController();
  final CategoryService _categoryService = CategoryService();

  Future<void> _fetchProducts(String categoryId) async {
    final products = await _vendorProductController.getProductsByVendorAndCategory(widget.vendorId, categoryId);
    setState(() {
      _vendorProducts = products;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Welcome to ${widget.vendorName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<List<Category>>(
              stream: _categoryService.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    items: snapshot.data!
                        .map((category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                      if (value != null) _fetchProducts(value);
                    },
                    decoration: const InputDecoration(labelText: 'What are you craving for today?'),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedCategoryId == null
                  ? const Center(child: Text('Select a category to view products.'))
                  : _vendorProducts.isEmpty
                      ? const Center(child: Text('No products in this category.'))
                      : ListView.builder(
                          itemCount: _vendorProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: _vendorProducts[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}



class ProductCard extends StatefulWidget {
  final VendorProduct product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 0;
  bool _isAddedToCart = false;

  void _decreaseQuantity() {
    setState(() {
      if (_quantity > 0) _quantity--;
      if (_quantity == 0) _isAddedToCart = false;
    });
  }

  void _increaseQuantity() {
    setState(() {
      if (_quantity < widget.product.quantity) {
        _quantity++;
        _isAddedToCart = true;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl = product.imageUrl?.isNotEmpty == true
        ? product.imageUrl!
        : 'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 80,
                    width: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 80,
                    width: 80,
                    child: Center(
                      child: Icon(Icons.error, color: Colors.red, size: 40),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Price: \$${product.price} / ${product.unit}'),
                  const SizedBox(height: 4),
                  if (product.isAvailable) ...[
                    Text('Quantity: ${product.quantity}'),
                    const SizedBox(height: 4),
                  ],
                  if (!product.isAvailable)
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Not Available", style: TextStyle(color: Colors.white)),
                    )
                  else if (!_isAddedToCart)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isAddedToCart = true;
                          _quantity = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _decreaseQuantity,
                          color: _quantity > 0 ? Colors.blue : Colors.grey,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$_quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _increaseQuantity,
                          color: _quantity < product.quantity ? Colors.blue : Colors.grey,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
