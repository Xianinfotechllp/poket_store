import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:poketstore/view/home/widgets/home_widgets.dart';
import 'package:poketstore/view/notification/notification.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Sample banner images
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

  final List<Map<String, dynamic>> _products = [
    {
      "image": "assets/product1.png",
      "name": "Beef Bone",
      "weight": "1Kg, Price",
      "price": "₹4,99",
    },
    {
      "image": "assets/product1.png",
      "name": "Chicken Wings",
      "weight": "500g, Price",
      "price": "₹2,99",
    },
    {
      "image": "assets/product1.png",
      "name": "Pork Ribs",
      "weight": "1Kg, Price",
      "price": "₹5,99",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: SizedBox(
          width: 63,
          height: 57,
          child: Image(image: AssetImage("assets/name.png")),
        ),
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Container(
        //     color: Colors.black,
        //     height: 150, // Increase the height
        //     width: 140, // Increase the width
        //     child: Image.asset('assets/name.png', fit: BoxFit.contain),
        //   ),
        // ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_business_outlined,
              color: Colors.blue.shade900,
            ),
            onPressed: () {
              // Handle notification tap
            },
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
                child: const TextField(
                  decoration: InputDecoration(
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
                height: 100, // Increased height for better visuals
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
            SizedBox(
              // height: 120, // Ensure height for scrollable horizontal list
              child: groceriesHorizontalList(_groceryItems),
            ),

            // Stores Section
            buildSectionTitle("Stores", "See all"),
            storeHorizontalList(_groceryItems),
            SizedBox(height: 20),
            // Spacer container with a defined height
            // buildSectionTitle("Exclusive Offers", "See all"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(),
                  ),
                );
              },
              child: productHorizontalList(_products),
            ),

            // Exclusive Offer Section
            buildSectionTitle("Exclusive Offer", "See all"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(),
                  ),
                );
              },
              child: productHorizontalList(_products),
            ),
            buildSectionTitle("Best Selling", "See all"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(),
                  ),
                );
              },
              child: productHorizontalList(_products),
            ),
          ],
        ),
      ),
    );
  }
}
