import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/vendor_service.dart';
import '../model/vendor_model.dart';
import 'adding_category_product.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final _categoryService = CategoryService();
  final _productService = ProductService();
  String? _selectedCategoryId;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = null; // Initialize to null
  }

  Future<void> _fetchProductsByCategory(String categoryId) async {


    _productService.getProducts().listen((products) {
      if (mounted) {
        setState(() {
          _products = products.where((product) => product.categoryId == categoryId).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Haricot Farms'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 80,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('product manager.'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryProductManager()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Section
                    Image.network(
                      "https://cdn.marketwurks.com/images/725a604371054c75111f99b23ce5ba57/20220518-145903-5523.jpg?auto=compress&w=1200&h=1200&fit=max",
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Haricot Farms',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Owner: Maxine & Bill'),
                          Text('Email: haricotfarms@gmail.com'),
                          Text('Phone: 7095212890'),
                          Text('Website: https://haricotfarms.localline.ca/'),
                          Text('Facebook: https://www.facebook.com/haricotfarms'),
                          Text('Instagram: https://www.instagram.com/haricotfarms'),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:MainAxisSize.min,
                    children: [
                      Text(
                        'Store Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Nestled in St. Mary’s Bay, our family has been farming since 1955. Over those years the farm has evolved. After 28 years’ operating a dairy farm, we became a provincially licensed, federally monitored, abattoir.'),

                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:MainAxisSize.min,
                    children: [
                      Text(
                        'Confirmed Dates:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Sat, 5 Apr 2025\nSat, 3 May 2025\nSat, 31 May 2025'),
                    ],
                  ),
                ),
              ),
              
              StreamBuilder<List<Category>>(
                stream:  _categoryService.getCategories(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    final categories = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      items: categories.map((category){
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                          if(value != null){
                            _fetchProductsByCategory(value);
                          }
                        });
                      },
                      decoration: InputDecoration(labelText: 'Select Category'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
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
                    : _products.isEmpty
                    ? Center(child: Text('No products in this category.'))
                    : ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ListTile(
                            title: Text(product.name),
                  

                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}