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
import 'package:poketstore/view/product_search/product_search.dart';
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
  bool _isDataLoaded = false;

  final List<String> _bannerImages = [
    'assets/slider.png',
    'assets/slider.png',
    'assets/slider.png',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _locationMapController =
          Provider.of<LocationMapController>(context, listen: false);
      _homeProductController =
          Provider.of<HomeProductController>(context, listen: false);
      _loadInitialData();
      _isDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Remove listener
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
    ).then((_) {
      _loadInitialData(); // Refresh when returning from Map screen
    });

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

    // Ensure _allProducts is updated from the controller whenever the controller notifies changes
    _allProducts = _homeProductController.products;
    // If search is active, keep filtered products, otherwise, update with all products
    if (_searchController.text.isEmpty) {
      _filteredProducts = _allProducts;
    }

    List<ShopModel> shopsWithProducts = shopProvider.shops;

    final displayedGroceries = _showAllGroceries
        ? groceryProvider.groceriesList.keyWithCategory
        : Map<String, List<String>>.fromEntries(
            groceryProvider.groceriesList.keyWithCategory.entries.take(3),
          );

    final displayedStores =
        _showAllStores ? shopsWithProducts : shopsWithProducts.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Poket',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Stor',
                style: TextStyle(color: Color(0xFFFFEA00)),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductSearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_business_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddShop()),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.notifications_none_sharp, color: Colors.white),
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
                      // --- SEARCH BAR (Moved to top) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                      // --- END SEARCH BAR ---

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
                                ? "${locationMapProvider.locationMap?.locality},${locationMapProvider.locationMap?.state} - ${locationMapProvider.locationMap?.pincode}"
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
                      // The search bar was here, moved up!

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
          Expanded(
            // Use Expanded to prevent overflow for long shop names
            child: Text(
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background with shop image and rounded bottom corners
          Container(
            height: 220,
            // decoration: BoxDecoration(
            //   borderRadius: const BorderRadius.only(
            //     bottomLeft: Radius.circular(40),
            //     bottomRight: Radius.circular(40),
            //   ),
            //   image: DecorationImage(
            //     image: NetworkImage(
            //       shop.shopImage.isNotEmpty
            //           ? shop.shopImage
            //           : 'https://via.placeholder.com/600x300',
            //     ),
            //     fit: BoxFit.cover,
            //   ),
            // ),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.black.withOpacity(0.4), // Semi-transparent overlay
              child: Text(
                shop.shopName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Product grid comes below the background
          Padding(
            padding: const EdgeInsets.only(top: 240),
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      "No products available in this shop.",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
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
                              builder: (context) => ProductDetailsScreen(
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image.network(
                                  product.productImage.isNotEmpty
                                      ? product.productImage
                                      : 'https://via.placeholder.com/150',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${product.price > 0 ? product.price : 'N/A'}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
