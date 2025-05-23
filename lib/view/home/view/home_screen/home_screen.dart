import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/groceries_list_controller/groceries_list_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:poketstore/view/home/view/store_horizontal_scroll/product_by_shop.dart';
import 'package:poketstore/view/home/widgets/home_widgets.dart';
import 'package:poketstore/view/home/widgets/map_location.dart';
import 'package:poketstore/view/notification/notification.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _searchController = TextEditingController();
  late LocationMapController _locationMapController;
  late HomeProductController _homeProductController;
  bool _isDataLoaded =
      false; // Add a flag to prevent redundant loading in didChangeDependencies

  final List<String> _bannerImages = [
    'assets/slider.png',
    'assets/slider.png',
    'assets/slider.png',
  ];

  @override
  void initState() {
    super.initState();
    log("🏠 HomeScreen initialized");
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load data if it hasn't been loaded yet or if you specifically want to reload
    // For a full "reload whenever entering this page" behavior, you can remove the _isDataLoaded check
    // or reset _isDataLoaded to false when navigating away from this screen.
    if (!_isDataLoaded) {
      // Consider removing this check if you want it to always reload
      _locationMapController =
          Provider.of<LocationMapController>(context, listen: false);
      _homeProductController =
          Provider.of<HomeProductController>(context, listen: false);
      _loadInitialData();
      _isDataLoaded = true; // Set the flag after initial load
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true; // Set loading to true at the start of data fetching
      _errorMessage = null; // Clear any previous error messages
    });
    try {
      log("⏳ Fetching data in HomeScreen didChangeDependencies");

      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      await Future.wait([
        _homeProductController.loadProducts(),
        Provider.of<ShopProvider>(context, listen: false).fetchShops(),
        if (_userId != null) _locationMapController.loadUserLocation(_userId!),
        Provider.of<GroceriesListProvider>(context, listen: false)
            .loadGroceriesList(),
      ]);

      _allProducts = _homeProductController.products;
      _filteredProducts = _allProducts;

      log("✅ Data fetching completed");
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to load data: $error";
      });
      log("❌ Error fetching data: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapLocationScreen()),
    );

    if (result != null && result is LocationMapModel && _userId != null) {
      await _locationMapController.updateUserLocation(_userId!, result);
      await _locationMapController.loadUserLocation(_userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final groceryProvider = Provider.of<GroceriesListProvider>(context);
    final locationMapProvider = Provider.of<LocationMapController>(context);

    _allProducts = _homeProductController.products;

    List<ShopModel> shopsWithProducts = shopProvider.shops.where((shop) {
      return _allProducts.any((product) => product.shop.id == shop.id);
    }).toList();

    final displayedGroceries = _showAllGroceries
        ? groceryProvider.groceriesList.keyWithCategory
        : Map<String, List<String>>.fromEntries(
            groceryProvider.groceriesList.keyWithCategory.entries.take(3),
          );

    final displayedStores =
        _showAllStores ? shopsWithProducts : shopsWithProducts.take(3).toList();
    // _homeProductController.loadProducts();
    // Provider.of<ShopProvider>(context, listen: false).fetchShops();
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
                            locationMapProvider.locationMap != null
                                ? "${locationMapProvider.locationMap?.state} - ${locationMapProvider.locationMap?.pincode}"
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
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: displayedStores.length,
                          itemBuilder: (context, index) {
                            final shop = displayedStores[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopProductsScreen(
                                        shop: shop), // Pass the shop object
                                  ),
                                );
                              },
                              child: buildStoreItem(
                                  shop.shopName, Colors.blue.shade100),
                            );
                          },
                        ),
                      ),
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

Widget buildStoreItem(String name, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 10),
    height: 100,
    width: 150,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class ShopProductsScreen extends StatelessWidget {
  final ShopModel shop;

  const ShopProductsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<HomeProductController>(context, listen: false)
        .products
        .where((product) => product.shop.id == shop.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(shop.shopName),
      ),
      body: products.isEmpty
          ? const Center(child: Text("No products available in this shop."))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopProductListScreen(
                            shopId: shop.id ?? "",
                            shopName: shop.shopName ?? "Unnamed Shop"),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.productImage.isNotEmpty
                                  ? Image.network(
                                      product.productImage,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Image.network(
                                      "https://via.placeholder.com/150",
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.productType,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${product.price > 0 ? product.price : 'N/A'}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
