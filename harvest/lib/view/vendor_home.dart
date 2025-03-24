import 'package:flutter/material.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  late List<String> _categories = ['Fruits','Vegetables','Nuts','seeds'];
  late Map<String, List<String>> categoriesAndItems = {
    'Fruits': ['Apple', 'Banana', 'Orange', 'Grapes'],
    'Vegetables': ['Carrot', 'Broccoli', 'Spinach'],
    'Nuts': ['Laptop', 'Smartphone', 'Tablet', 'Headphones', 'Keyboard'],
    'seeds': ['Fiction', 'Non-Fiction', 'Science Fiction'],
  };
  late PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Haricot Farms')),
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
              SizedBox(
                height: 50,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _categories.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Colors.blue : Colors.grey,
                      ),
                    ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  itemCount: categoriesAndItems[_categories[_currentPage]]?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(categoriesAndItems[_categories[_currentPage]]?[index] ?? ''),
                    );
                  },
                ),
              ),
              SizedBox(height: 16)
            ],
          ),
        ),
      ),
    );
  }
}