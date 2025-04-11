import 'package:flutter/material.dart';
import 'package:harvest/view/notification_manger_page.dart';
import '../controller/vendor_service.dart';
import '../model/vendor_model.dart';
import 'adding_category_product.dart';
import 'vendor_registration.dart';
import 'product_edit_screen.dart';
import 'vendor_review_page.dart';  

class VendorHomePage extends StatefulWidget {
  final String vendorId;
  const VendorHomePage({super.key, required this.vendorId});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _categoryService = CategoryService();
  final _vendorProduct = VendorProductController();
  final _vendorService = VendorService();

  String? _selectedCategoryId;
  List<VendorProduct> _filteredVendorProducts = [];
  static const String _defaultImageUrl = 'https://img.freepik.com/premium-vector/fresh-vegetable-logo-design-illustration_1323048-66973.jpg?w=740';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); 
  }

  Future<void> _filterVendorProducts(String categoryId) async {
    final vendorProducts = await _vendorProduct.getProductsByVendorAndCategory(widget.vendorId, categoryId);
    setState(() {
      _filteredVendorProducts = vendorProducts;
    });
  }

  void _openVendorEditDialog(Vendor vendor) async {
    await showDialog(
      context: context,
      builder: (context) =>
          Dialog(child: VendorRegistrationPage(vendor: vendor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: StreamBuilder<Vendor?>(
          stream: _vendorService.getVendor(widget.vendorId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final vendor = snapshot.data!;
            return Text(
              vendor.vendor_name,
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Home'),
            Tab(text: 'Reviews'),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Options',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            ListTile(
              title: Text('Product Manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CategoryProductManager(vendorId: widget.vendorId)),
                );
              },
            ),
            ListTile(
              title: Text('Notification Manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificationPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder<Vendor?>(
            stream: _vendorService.getVendor(widget.vendorId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final vendor = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onLongPress: () => _openVendorEditDialog(vendor),
                        //onLongPress: null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withAlpha((0.3 * 255).toInt()),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.network(
                                vendor.store_img.isNotEmpty
                                    ? vendor.store_img
                                    : "https://sjfm.ca/wp-content/uploads/2018/07/FarmersMarketLauchLogo.jpg",
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: Icon(Icons.store,
                                      size: 40, color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(vendor.vendor_name,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text('Email: ${vendor.email}'),
                                    Text('Phone: ${vendor.phone}'),
                                    if (vendor.website != null)
                                      Text('Website: ${vendor.website}'),
                                    if (vendor.facebook != null)
                                      Text('Facebook: ${vendor.facebook}'),
                                    if (vendor.instagram != null)
                                      Text('Instagram: ${vendor.instagram}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (vendor.store_descrip.isNotEmpty)
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Store Description',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text(vendor.store_descrip),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      if (vendor.conf_dates.isNotEmpty)
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Confirmed Dates:',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text(vendor.conf_dates.join("\n")),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
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
                                  if (value != null) _filterVendorProducts(value);
                                });
                              },
                              decoration:
                                  InputDecoration(labelText: 'Select Category'),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: Builder(
                          builder: (context) {
                            if (_selectedCategoryId == null) {
                              return Center(
                                child: Text('Select a category to view products.'),
                              );
                            }
                            if (_filteredVendorProducts.isEmpty) {
                              return Center(
                                child: Text('No products in this category.'),
                              );
                            }
                            return ListView.builder(
                              itemCount: _filteredVendorProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredVendorProducts[index];
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                                          ? product.imageUrl!
                                          : _defaultImageUrl,
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
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  title: Text(product.productName),
                                  subtitle: Text('Price: \$${product.price} | Qty: ${product.quantity} ${product.unit}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => updateProduct(vendorProduct: product),
                                            ),
                                          );
                                          if (_selectedCategoryId != null) {
                                            await _filterVendorProducts(_selectedCategoryId!);
                                          }
                                        },
                                      ),
                                      Icon(
                                        product.isAvailable ? Icons.check_circle : Icons.cancel,
                                        color: product.isAvailable ? Colors.green : Colors.red,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          VendorReviewPage(vendorId: widget.vendorId),

        ],
      ),
    );
  }
}
