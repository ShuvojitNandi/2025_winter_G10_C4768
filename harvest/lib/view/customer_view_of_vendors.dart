import 'package:flutter/material.dart';
import 'package:harvest/controller/vendor_service.dart';
import 'package:harvest/model/vendor_model.dart';
import 'package:harvest/controller/cart_controller.dart';
import 'package:harvest/model/cart_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../controller/review_controller.dart';
import '../model/product_review.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Welcome to ${widget.vendorName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightGreen),
              child: Text('Options',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            ListTile(
              title: Text('Store Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          vendorinfo(vendorId: widget.vendorId)),
                );
              },
            ),

          ],
        ),
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


class vendorinfo extends StatefulWidget{
  final String vendorId;
  const vendorinfo({super.key, required this.vendorId});
  @override
  State<vendorinfo> createState() => _vendorinfoState();
}

class _vendorinfoState extends State<vendorinfo> {
  static const String _defaultImageUrl = 'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740';
  final _vendorService = VendorService();
  final _reviewService = ReviewController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: StreamBuilder<Vendor?>(
        stream: _vendorService.getVendor(widget.vendorId),
        builder: (context, vendorSnapshot) {
          if (!vendorSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final vendor = vendorSnapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    vendor.store_img.isNotEmpty
                        ? vendor.store_img
                        : "https://sjfm.ca/wp-content/uploads/2018/07/FarmersMarketLauchLogo.jpg",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Placeholder(),
                  ),
                  title: Text(
                    vendor.vendor_name,
                    style: TextStyle(color: Colors.white, shadows: [
                      Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                    ]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.person, vendor.vendor_name),
                          _buildInfoRow(Icons.email, vendor.email),
                          _buildInfoRow(Icons.phone, vendor.phone),
                          if (vendor.website != null)
                            _buildInfoRow(Icons.link, vendor.website!),
                          if (vendor.facebook != null)
                            _buildInfoRow(Icons.facebook, vendor.facebook!),
                          SizedBox(height: 12),
                          Text("About", style: Theme.of(context).textTheme.titleMedium),
                          Text(vendor.store_descrip ?? "No description provided"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contract Dates",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          if (vendor.conf_dates == null || vendor.conf_dates!.isEmpty)
                            Text("No contract dates available"),
                          if (vendor.conf_dates != null && vendor.conf_dates!.isNotEmpty)
                            Column(
                              children: vendor.conf_dates!.map((date) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                    SizedBox(width: 10),
                                    Text(
                                      _formatDate(date), // Use date formatting function
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false, // Remove back button behavior
                backgroundColor: Colors.white,
                elevation: 1, // Small shadow
                titleSpacing: 0, // Align with other content
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Customer Reviews",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                toolbarHeight: 48, // Compact height
              ),
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: StreamBuilder<List<Review>>(
                  stream: _reviewService.getReviewsByVendorId(widget.vendorId).asStream(),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }
                    final reviews = snapshot.data ?? [];
                    if (reviews.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            "No reviews yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= reviews.length) return null;
                            return _buildReviewCard(reviews[index]);
                          },
                        childCount: reviews.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 10),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date); // Requires 'intl' package
    } catch (e) {
      return dateString; // Fallback to raw string if parsing fails
    }
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Text(review.userName[0]),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(review.timestamp.toDate().toString()),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Spacer(),
                _buildRatingStars(review.rating.toInt()),
              ],
            ),

            SizedBox(height: 12),

            // Review Content
            Text(review.comment),

            // Review Image (if exists)
            if (review.imageUrl != null && review.imageUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    review.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20,
      )),
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

