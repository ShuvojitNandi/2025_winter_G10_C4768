import 'package:flutter/material.dart';
import '../controller/vendor_service.dart';
import '../model/vendor_model.dart';
import 'adding_category_product.dart';
import 'vendor_registration.dart';

class VendorHomePage extends StatefulWidget {
  final String vendorId;
  const VendorHomePage({super.key, required this.vendorId});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _categoryService = CategoryService();
  final _productService = ProductService();
  final _vendorService = VendorService();

  String? _selectedCategoryId;
  List<Product> _allProducts = [];
  List<String> _filteredProductIds = [];

  @override
  void initState() {
    super.initState();
    _loadGlobalProducts();
  }

  Future<void> _loadGlobalProducts() async {
    _productService.getProducts().listen((products) {
      setState(() {
        _allProducts = products;
      });
    });
  }

  Future<void> _filterVendorProducts(String categoryId) async {
    _productService.getVendorProductsStream(widget.vendorId).listen((vendorProducts) {
      final filtered = vendorProducts
          .where((vp) {
            final product = _allProducts.firstWhere(
              (p) => p.id == vp['productId'],
              orElse: () => Product(id: '', name: '', categoryId: ''),
            );
            return product.categoryId == categoryId;
          })
          .map((vp) => vp['productId'].toString())
          .toList();

      setState(() {
        _filteredProductIds = filtered;
      });
    });
  }

  void _openVendorEditDialog(Vendor vendor) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(child: VendorRegistrationPage(vendor: vendor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Vendor Profile'),
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
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Options', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            ListTile(
              title: Text('Product Manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryProductManager(vendorId: widget.vendorId)),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<Vendor?>(
        stream: _vendorService.getVendor(widget.vendorId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final vendor = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () => _openVendorEditDialog(vendor),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
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
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: Icon(Icons.store, size: 40, color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vendor.vendor_name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('Email: ${vendor.email}'),
                                Text('Phone: ${vendor.phone}'),
                                if (vendor.website != null) Text('Website: ${vendor.website}'),
                                if (vendor.facebook != null) Text('Facebook: ${vendor.facebook}'),
                                if (vendor.instagram != null) Text('Instagram: ${vendor.instagram}'),
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
                            Text('Store Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            Text('Confirmed Dates:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          decoration: InputDecoration(labelText: 'Select Category'),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: _selectedCategoryId == null
                        ? Center(child: Text('Select a category to view products.'))
                        : _filteredProductIds.isEmpty
                            ? Center(child: Text('No products in this category.'))
                            : ListView.builder(
                                itemCount: _filteredProductIds.length,
                                itemBuilder: (context, index) {
                                  final productId = _filteredProductIds[index];
                                  final product = _allProducts.firstWhere((p) => p.id == productId);
                                  return ListTile(title: Text(product.name));
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
