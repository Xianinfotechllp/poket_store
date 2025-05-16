import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/groceries_list_controller/groceries_list_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:poketstore/view/home/widgets/home_widgets.dart';
import 'package:poketstore/view/home/widgets/map_location.dart';
import 'package:poketstore/view/notification/notification.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:poketstore/model/home_product_model/home_product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<LocationProduct> _allProducts = [];
  List<LocationProduct> _filteredProducts = [];
  String? _userId;
  bool _showAllGroceries = false;
  bool _showAllStores = false;
  LocationModel? _currentLocation;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _bannerImages = [
    'assets/slider.png',
    'assets/slider.png',
    'assets/slider.png',
  ];

  @override
  void initState() {
    super.initState();
    log("🏠 HomeScreen initialized");
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      log("⏳ Fetching data in HomeScreen initState");
      final locationProvider =
          Provider.of<LocationController>(context, listen: false);
      final locationProductProvider =
          Provider.of<HomeProductController>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      await locationProductProvider.loadProducts();
      await Provider.of<ShopProvider>(context, listen: false).fetchShops();
      if (_userId != null) {
        await locationProvider.getLocation(_userId!);
      }

      _allProducts = locationProductProvider.products;
      _filteredProducts = _allProducts;
      Provider.of<GroceriesListProvider>(context, listen: false)
          .loadGroceriesList();

      log("✅ Data fetching completed");
      setState(() {
        _isLoading = locationProductProvider.isLoading;
        _errorMessage = locationProductProvider.errorMessage;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load data: $error";
      });
      log("❌ Error fetching data: $error");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToMapScreen() async {
    final locationProvider =
        Provider.of<LocationController>(context, listen: false);
    await locationProvider.updateLocationFromGPS();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapLocationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final groceryProvider = Provider.of<GroceriesListProvider>(context);
    final locationProvider = Provider.of<LocationController>(context);
    final locationProductProvider = Provider.of<HomeProductController>(context);

    _currentLocation = locationProvider.location;
    _isLoading = locationProductProvider.isLoading;
    _errorMessage = locationProductProvider.errorMessage;
    _allProducts = locationProductProvider.products;

    final displayedGroceries = _showAllGroceries
        ? groceryProvider.groceriesList.keyWithCategory
        : Map<String, List<String>>.fromEntries(
            groceryProvider.groceriesList.keyWithCategory.entries.take(3),
          );

    final displayedStores = _showAllStores
        ? shopProvider.shops
        : shopProvider.shops.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Image.asset("assets/name.png", width: 63, height: 57),
        actions: [
          IconButton(
            icon:
                Icon(Icons.add_business_outlined, color: Colors.blue.shade900),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddShop())),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_sharp,
                color: Colors.blue.shade900),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => NotificationScreen())),
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
                          onPageChanged: (index, reason) =>
                              setState(() => _currentIndex = index),
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
                            horizontal: 16, vertical: 8),
                        child: InkWell(
                          onTap: _navigateToMapScreen,
                          child: Text(
                            _currentLocation != null
                                ? "${_currentLocation?.locality}, ${_currentLocation?.state} - ${_currentLocation?.pincode}"
                                : "Fetching location...",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ),
                      buildSectionTitle(
                          "Stores", _showAllStores ? "Show less" : "See all",
                          () {
                        setState(() => _showAllStores = !_showAllStores);
                      }),
                      displayedStores.isEmpty
                          ? const Center(child: Text("No Stores Found"))
                          : storeHorizontalList(displayedStores),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search products...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildSectionTitle("Products", "", () {}),
                      _filteredProducts.isEmpty
                          ? const Center(child: Text("No Products Found"))
                          : productGridView(_filteredProducts.map((product) {
                              return {
                                "_id": product.id,
                                "image": product.productImage.isNotEmpty
                                    ? product.productImage
                                    : "https://via.placeholder.com/150",
                                "name": product.name,
                                "weight": product.productType,
                                "price":
                                    "₹${product.price > 0 ? product.price : 'N/A'}",
                              };
                            }).toList()),
                    ],
                  ),
                ),
    );
  }

  Widget buildSectionTitle(
      String title, String actionText, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          InkWell(
            onTap: onTap,
            child:
                Text(actionText, style: TextStyle(color: Colors.blue.shade700)),
          ),
        ],
      ),
    );
  }
}
