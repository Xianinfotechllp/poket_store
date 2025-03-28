import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:poketstore/view/home/widgets/home_widgets.dart';
import 'package:poketstore/view/notification/notification.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String searchQuery = "";

  final List<String> _bannerImages = [
    'assets/slider.png',
    'assets/slider.png',
    'assets/slider.png',
  ];

  final List<Map<String, dynamic>> _groceryItems = [
    {"name": "Vegetables", "color": Colors.green.shade200},
    {"name": "Dairy Products", "color": Colors.blue.shade200},
    {"name": "Beverages", "color": Colors.red.shade200},
    {"name": "Snacks", "color": Colors.orange.shade200},
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<FetchProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<FetchProductProvider>(context);

    // Filter products based on search query
    final filteredProducts =
        productProvider.products.where((product) {
          return product.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: SizedBox(
          width: 63,
          height: 57,
          child: Image.asset("assets/name.png"),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_business_outlined,
              color: Colors.blue.shade900,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_sharp,
              color: Colors.blue.shade900,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search Store',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            // Carousel Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 100,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 3),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items:
                  _bannerImages.map((imagePath) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 10),
            // Page Indicator
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: _bannerImages.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.blue,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
            // Groceries Section
            buildSectionTitle("Groceries", "See all"),
            SizedBox(child: groceriesHorizontalList(_groceryItems)),
            // Stores Section
            buildSectionTitle("Stores", "See all"),
            storeHorizontalList(_groceryItems),
            const SizedBox(height: 20),
            // Products Section with Search Applied
            productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productGridView(
                  filteredProducts.map((product) {
                    return {
                      "_id": product.id,
                      "image": product.productImage,
                      "name": product.name,
                      "weight": product.productType,
                      "price": "₹${product.price}",
                    };
                  }).toList(),
                ),
          ],
        ),
      ),
    );
  }
}
