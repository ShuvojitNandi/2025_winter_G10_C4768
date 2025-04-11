import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:harvest/controller/cart_controller.dart';
import 'package:harvest/controller/vendor_service.dart';
import 'package:harvest/model/cart_model.dart';
import 'package:harvest/model/vendor_model.dart';
import 'after_payment_review.dart';

class CartPage extends StatefulWidget {
  final String userId;
  final String userName;

  const CartPage({super.key, required this.userId, required this.userName});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController _cartController = CartController();
  final VendorProductController _vendorProductController = VendorProductController();
  late Future<Map<String, List<CartItem>>> _groupedCart;

  @override
  void initState() {
    super.initState();
    _groupedCart = _cartController.getGroupedCartItemsByVendor(widget.userId);
  }

  Future<void> _refreshCart() async {
    setState(() {
      _groupedCart = _cartController.getGroupedCartItemsByVendor(widget.userId);
    });
  }

  Future<String> _getVendorName(String vendorId) async {
    final doc = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
    if (doc.exists) {
      return doc['vendor_name'] ?? vendorId;
    }
    return vendorId;
  }

  Future<void> _editQuantityDialog(CartItem item) async {
    int newQty = item.quantity;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: TextFormField(
          initialValue: newQty.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            newQty = int.tryParse(val) ?? item.quantity;
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final updatedItem = CartItem(
                id: item.id,
                userId: item.userId,
                vendorId: item.vendorId,
                productId: item.productId,
                quantity: newQty,
                unitPrice: item.unitPrice,
                totalPrice: newQty * item.unitPrice,
                isPaid: false,
                timestamp: Timestamp.now(),
              );
              await _cartController.addOrUpdateCartItem(updatedItem);
              Navigator.pop(context);
              _refreshCart();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(List<CartItem> vendorItems) async {
    for (final item in vendorItems) {
      final product = await _vendorProductController.getVendorProductByProductId(item.productId);
      if (product != null) {
        product.quantity -= item.quantity;
        if (product.quantity <= 0) {
          product.quantity = 0;
          product.isAvailable = false;
        }
        await _vendorProductController.updateVendorProduct(product);
      }
      await _cartController.markItemAsPaid(item.id!);
    }
    await _refreshCart();

   
    final String vendorId = vendorItems.first.vendorId;
    final List<String> purchasedProductIds = vendorItems.map((item) => item.productId).toList();

    await _showReviewDialog(vendorId, purchasedProductIds);
  }

  Future<void> _showReviewDialog(String vendorId, List<String> purchasedProductIds) async {
    await showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlertDialog(
        content: const Text("Can you please spare a minute to review the products you just purchased?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AllVendorProductsPage(
                    userId: widget.userId,
                    userName: widget.userName,
                    purchasedProductIds: purchasedProductIds,
                  ),
                ),
              );
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/'); // back to homepage
            },
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(CartItem item) {
    return FutureBuilder<VendorProduct?>(
      future: _vendorProductController.getVendorProductByProductId(item.productId),
      builder: (context, snapshot) {
        final product = snapshot.data;
        final imageUrl = product?.imageUrl?.isNotEmpty == true
            ? product!.imageUrl!
            : 'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740';
        final productName = product?.productName ?? item.productId;
        final unitPrice = product?.price ?? item.unitPrice;
        final unit = product?.unit ?? "";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl, height: 50, width: 50, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Unit Price: \$${unitPrice.toStringAsFixed(2)} / $unit"),
                    Text("Qty: ${item.quantity}"),
                    Text("Total: \$${item.totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => _editQuantityDialog(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.green),
                onPressed: () async {
                  await _cartController.deleteCartItem(item.id!);
                  _refreshCart();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart"), backgroundColor: Colors.green),
      body: FutureBuilder(
        future: _groupedCart,
        builder: (context, AsyncSnapshot<Map<String, List<CartItem>>> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final grouped = snapshot.data!;
          if (grouped.isEmpty) return const Center(child: Text("Your cart is empty"));

          return RefreshIndicator(
            onRefresh: _refreshCart,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: grouped.entries.map((entry) {
                final vendorId = entry.key;
                final items = entry.value;
                final total = items.fold(0.0, (sum, item) => sum + item.totalPrice);

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: _getVendorName(vendorId),
                          builder: (context, vendorSnapshot) {
                            final name = vendorSnapshot.data ?? vendorId;
                            return Text(
                              "Vendor: $name",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const Divider(),
                        ...items.map(_buildProductRow),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: \$${total.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: () => _placeOrder(items),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text("PLACE ORDER"),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
