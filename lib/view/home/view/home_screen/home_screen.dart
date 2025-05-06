import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/groceries_list_controller/groceries_list_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:poketstore/view/home/widgets/home_widgets.dart';
import 'package:poketstore/view/home/widgets/map_location.dart';
import 'package:poketstore/view/notification/notification.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];

  bool _showAllGroceries = false;
  bool _showAllStores = false;

  final List<String> _bannerImages = [
    'assets/slider.png',
    'assets/slider.png',
    'assets/slider.png',
  ];

  // final List<Map<String, dynamic>> _groceryItems = [
  //   {"name": "Vegetables", "color": Colors.green.shade200},
  //   {"name": "Dairy Products", "color": Colors.blue.shade200},
  //   {"name": "Beverages", "color": Colors.red.shade200},
  //   {"name": "Snacks", "color": Colors.orange.shade200},
  //   {"name": "Fruits", "color": Colors.purple.shade200},
  // ];

  @override
  void initState() {
    super.initState();
    log("🏠 HomeScreen initialized");
    _loadInitialData();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      log("⏳ Fetching data in HomeScreen initState");
      final productProvider = Provider.of<HomeProductController>(
        context,
        listen: false,
      );
      await productProvider.loadHomeProducts();
      await Provider.of<ShopProvider>(context, listen: false).fetchShops();
      _allProducts = List.from(productProvider.homeProducts);
      _filteredProducts = List.from(_allProducts);

      Provider.of<LocationController>(context, listen: false).getLocation();
      Provider.of<GroceriesListProvider>(context, listen: false).loadGroceriesList();
      setState(() {
        _isLoading = false;
      });
      log("✅ Data fetching completed");
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load data: $error";
      });
      log("❌ Error fetching data: $error");
    }
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts
          .where(
            (product) => (product.name ?? "").toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _navigateToMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapLocationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final groceryProvider = Provider.of<GroceriesListProvider>(context);
    final displayedGroceries = _showAllGroceries
        ? groceryProvider.groceriesList.keyWithCategory
        : Map<String, List<String>>.fromEntries(
            groceryProvider.groceriesList.keyWithCategory.entries.take(3),
          );

    final displayedStores = _showAllStores ? shopProvider.shops : shopProvider.shops.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Image.asset("assets/name.png", width: 63, height: 57),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_business_outlined,
              color: Colors.blue.shade900,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddShop()),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_sharp,
              color: Colors.blue.shade900,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 100,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          onPageChanged: (index, reason) => setState(() => _currentIndex = index),
                        ),
                        items: _bannerImages.map((imagePath) {
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: InkWell(
                          onTap: _navigateToMapScreen,
                          child: Consumer<LocationController>(
                            builder: (context, locationController, _) {
                              final location = locationController.location;
                              return Text(
                                location != null ? "${location.locality}, ${location.state} - ${location.pincode}" : "Fetching location...",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.deepOrange,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      buildSectionTitle(
                        "Groceries",
                        _showAllGroceries ? "Show less" : "See all",
                        () {
                          setState(() => _showAllGroceries = !_showAllGroceries);
                        },
                      ),
                      displayedGroceries.isEmpty
                          ? const Center(child: Text("No Groceries Found"))
                          : groceriesHorizontalList(displayedGroceries, context),
                      buildSectionTitle(
                        "Stores",
                        _showAllStores ? "Show less" : "See all",
                        () {
                          setState(() => _showAllStores = !_showAllStores);
                        },
                      ),
                      displayedStores.isEmpty ? const Center(child: Text("No Stores Found")) : storeHorizontalList(displayedStores),
                      const SizedBox(height: 20),
                      _filteredProducts.isEmpty
                          ? const Center(child: Text("No Products Found"))
                          : productGridView(
                              _filteredProducts.map((product) {
                                return {
                                  "_id": product.id,
                                  "image": product.productImage.isNotEmpty ? product.productImage : "https://via.placeholder.com/150",
                                  "name": product.name,
                                  "weight": product.productType,
                                  "price": "₹${product.price > 0 ? product.price : 'N/A'}",
                                };
                              }).toList(),
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget buildSectionTitle(
    String title,
    String actionText,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              actionText,
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
