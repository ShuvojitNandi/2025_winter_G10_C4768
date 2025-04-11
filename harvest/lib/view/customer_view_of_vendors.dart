import 'package:flutter/material.dart';
import 'package:harvest/controller/vendor_service.dart';
import 'package:harvest/model/vendor_model.dart';
import 'package:harvest/controller/cart_controller.dart';
import 'package:harvest/model/cart_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerVendorPage extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String customerId;

  const CustomerVendorPage({
    super.key,
    required this.vendorId,
    required this.vendorName,
    required this.customerId,
  });

  @override
  State<CustomerVendorPage> createState() => _CustomerVendorPageState();
}


class _CustomerVendorPageState extends State<CustomerVendorPage> {
  String? _selectedCategoryId = '';
  List<VendorProduct> _vendorProducts = [];
  List<CartItem> _existingCartItems = [];

  final VendorProductController _vendorProductController = VendorProductController();
  final CategoryService _categoryService = CategoryService();
  final CartController _cartController = CartController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final allProducts = await _vendorProductController.getVendorAllProduct(widget.vendorId);
    final cartItems = await _cartController.getUserCartItems(widget.customerId);
    setState(() {
      _vendorProducts = allProducts;
      _existingCartItems = cartItems;
    });
  }

  Future<void> _fetchProducts(String categoryId) async {
    final products = await _vendorProductController.getProductsByVendorAndCategory(widget.vendorId, categoryId);
    final cartItems = await _cartController.getUserCartItems(widget.customerId);
    setState(() {
      _vendorProducts = products;
      _existingCartItems = cartItems;
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
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text("Explore all products"),
                      ),
                      ...snapshot.data!.map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                      if (value == null || value == '') {
                        _loadAllData();
                      } else {
                        _fetchProducts(value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Explore all products',
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _vendorProducts.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : ListView.builder(
                      itemCount: _vendorProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          key: ValueKey(_vendorProducts[index].productId),
                          product: _vendorProducts[index],
                          customerId: widget.customerId,
                          existingItems: _existingCartItems,
                        );
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
  final String customerId;
  final List<CartItem> existingItems;

  const ProductCard({
    super.key,
    required this.product,
    required this.customerId,
    required this.existingItems,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}


class _ProductCardState extends State<ProductCard> {
  int _quantity = 0;
  String? _cartItemId;
  bool _isAddedToCart = false;
  final CartController _cartController = CartController();

  @override
  void initState() {
    super.initState();
    _loadInitialQuantity();
  }

  void _loadInitialQuantity() {
    final match = widget.existingItems.firstWhere(
      (item) =>
          item.productId == widget.product.productId &&
          item.vendorId == widget.product.vendorId,
      orElse: () => CartItem(
        userId: '',
        vendorId: '',
        productId: '',
        quantity: 0,
        unitPrice: 0,
        totalPrice: 0,
        isPaid: false,
        timestamp: Timestamp.now(),
      ),
    );

    if (match.quantity > 0) {
      setState(() {
        _quantity = match.quantity;
        _cartItemId = match.id;
        _isAddedToCart = true;
      });
    }
  }

  void _updateCart() async {
    final cartItem = CartItem(
      id: _cartItemId,
      userId: widget.customerId,
      vendorId: widget.product.vendorId,
      productId: widget.product.productId,
      quantity: _quantity,
      unitPrice: widget.product.price,
      totalPrice: _quantity * widget.product.price,
      isPaid: false,
      timestamp: Timestamp.now(),
    );

    await _cartController.addOrUpdateCartItem(cartItem);
    if (_quantity == 0) {
      setState(() => _isAddedToCart = false);
    }
  }

  void _increaseQuantity() {
    if (_quantity < widget.product.quantity) {
      setState(() {
        _quantity++;
        _isAddedToCart = true;
      });
      _updateCart();
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        if (_quantity == 0) _isAddedToCart = false;
      });
      _updateCart();
    }
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, height: 80, width: 80, fit: BoxFit.cover),
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
                  if (product.isAvailable) Text('Quantity: ${product.quantity}'),
                  const SizedBox(height: 4),
                  if (!product.isAvailable)
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: const Text("Not Available", style: TextStyle(color: Colors.white)),
                    )
                  else if (!_isAddedToCart)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isAddedToCart = true;
                          _quantity = 1;
                        });
                        _updateCart();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
                    )
                  else
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove), onPressed: _decreaseQuantity),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                          child: Text('$_quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(icon: const Icon(Icons.add), onPressed: _increaseQuantity),
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

