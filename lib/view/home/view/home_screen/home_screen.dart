import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/fcm_controller/fcm_controller.dart';
import 'package:poketstore/controllers/groceries_list_controller/groceries_list_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart';
import 'package:poketstore/controllers/product_search_controller/product_search_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
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
import 'package:poketstore/model/product_search_model/product_search_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoadingInitialData = true;
  String? _initialErrorMessage;
  String? _userId;
  bool _showAllGroceries = false;
  bool _showAllStores = false;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  late LocationMapController _locationMapController;
  late HomeProductController _homeProductController;
  late ProductSearchProvider _productSearchProvider;
  bool _isDataLoaded = false;
  bool _isSearchExpanded = false;
  bool _showLocationField = false;
  final List<String> _bannerImages = [
    'assets/slider.png',
    'assets/slider.png',
    'assets/slider.png',
  ];

  @override
  void initState() {
    super.initState();
    _productNameController.addListener(_onSearchFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("Initiating FCM token registration after first frame.");
      Provider.of<FCMProvider>(
        context,
        listen: false,
      ).registerFcmToken(context);
    });
  }

  // New method to handle text field changes and collapse search bar
  void _onSearchFieldChanged() {
    if (_productNameController.text.isEmpty &&
        _localityController.text.isEmpty &&
        _isSearchExpanded) {
      setState(() {
        _isSearchExpanded = false;
        _showLocationField = false; // Collapse location field too
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _locationMapController = Provider.of<LocationMapController>(
        context,
        listen: false,
      );
      _homeProductController = Provider.of<HomeProductController>(
        context,
        listen: false,
      );
      _productSearchProvider = Provider.of<ProductSearchProvider>(
        context,
        listen: false,
      );
      _loadInitialData();
      _isDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _productNameController.removeListener(_onSearchFieldChanged);
    _productNameController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialErrorMessage = null;
    });
    try {
      log("⏳ Fetching initial data in HomeScreen");

      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      await Future.wait([
        _homeProductController.loadProducts(),
        Provider.of<ShopProvider>(context, listen: false).fetchShops(),
        if (_userId != null) _locationMapController.loadUserLocation(_userId!),
        Provider.of<GroceriesListProvider>(
          context,
          listen: false,
        ).loadGroceriesList(),
      ]);

      log("✅ Initial data fetching completed");
    } catch (error) {
      setState(() {
        _initialErrorMessage = "Failed to load initial data: $error";
      });
      log("❌ Error fetching initial data: $error");
    } finally {
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  void _performSearch() {
    final String productName = _productNameController.text.trim();
    final String locality = _localityController.text.trim();

    _productSearchProvider.fetchSearchResults(productName, locality);
    // Optionally, after search, you might want to collapse the search bar
    // if no location was entered and product name is cleared.
    if (productName.isEmpty && locality.isEmpty) {
      setState(() {
        _isSearchExpanded = false;
        _showLocationField = false;
      });
    }
  }

  void _navigateToMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapLocationScreen()),
    );
    if (result != null && result is LocationMapModel && _userId != null) {
      await _locationMapController.updateUserLocation(_userId!, result);
      await _locationMapController.loadUserLocation(_userId!);
      _loadInitialData();
    } else {
      _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final groceryProvider = Provider.of<GroceriesListProvider>(context);
    final locationMapProvider = Provider.of<LocationMapController>(context);
    final productSearchProvider = Provider.of<ProductSearchProvider>(context);

    List<Map<String, dynamic>> productsToDisplayFormatted;
    bool isSearching =
        _productNameController.text.isNotEmpty ||
        _localityController.text.isNotEmpty;

    if (isSearching && productSearchProvider.searchResults.isNotEmpty) {
      productsToDisplayFormatted =
          productSearchProvider.searchResults.map((product) {
            return {
              "_id": product.id,
              "image":
                  product.productImage.isNotEmpty
                      ? product.productImage
                      : "https://via.placeholder.com/150",
              "name": product.name,
              "weight": product.category,
              "price": "₹${product.price > 0 ? product.price : 'N/A'}",
            };
          }).toList();
    } else if (!isSearching) {
      productsToDisplayFormatted =
          _homeProductController.products.map((product) {
            return {
              "_id": product.id,
              "image":
                  product.productImage.isNotEmpty
                      ? product.productImage
                      : "https://via.placeholder.com/150",
              "name": product.name,
              "weight": product.productType,
              "price": "₹${product.price > 0 ? product.price : 'N/A'}",
            };
          }).toList();
    } else {
      productsToDisplayFormatted = [];
    }

    // --- Start of changes for filtering shops ---

    // Get a set of shop IDs from the currently displayed products
    final Set<String> shopIdsInDisplayedProducts = {};
    if (isSearching) {
      for (var product in productSearchProvider.searchResults) {
        if (product.shop != null && product.shop! != null) {
          shopIdsInDisplayedProducts.add(product.shop!);
        }
      }
    } else {
      for (var product in _homeProductController.products) {
        if (product.shop != null && product.shop!.id != null) {
          shopIdsInDisplayedProducts.add(product.shop!.id!);
        }
      }
    }

    // Filter shops based on whether their ID is in the set of shop IDs from displayed products
    List<ShopModel> filteredShops =
        shopProvider.shops
            .where((shop) => shopIdsInDisplayedProducts.contains(shop.id))
            .toList();

    // Now use filteredShops for displayedStores
    final displayedStores =
        _showAllStores ? filteredShops : filteredShops.take(3).toList();

    // --- End of changes for filtering shops ---

    // final displayedGroceries =
    //     _showAllGroceries
    //         ? groceryProvider.groceriesList.keyWithCategory
    //         : Map<String, List<String>>.fromEntries(
    //             groceryProvider.groceriesList.entries.take(3), // Accessing entries directly if keyWithCategory is Map<String, List<String>>
    //           );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body:
          _isLoadingInitialData
              ? const Center(child: CircularProgressIndicator())
              : _initialErrorMessage != null
              ? Center(child: Text(_initialErrorMessage!))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 100,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        onPageChanged:
                            (index, reason) =>
                                setState(() => _currentIndex = index),
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
                    const SizedBox(height: 20),
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
                      "Stores",
                      _showAllStores ? "Show less" : "See all",
                      () {
                        setState(() => _showAllStores = !_showAllStores);
                      },
                    ),
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
                                  builder:
                                      (context) =>
                                          ShopProductsScreen(shop: shop),
                                ),
                              );
                            },
                            child: buildStoreItem(
                              shop.shopName,
                              Colors.blue.shade100,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isSearching && productSearchProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (isSearching &&
                        productSearchProvider.errorMessage.isNotEmpty)
                      Center(
                        child: Text(
                          'Error: ${productSearchProvider.errorMessage}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (isSearching && productsToDisplayFormatted.isEmpty)
                      const Center(
                        child: Text(
                          'No products found matching your search.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (productsToDisplayFormatted.isEmpty)
                      const Center(child: Text("No Products Available"))
                    else
                      buildSectionTitle("Products", "", () {}),
                    productGridView(productsToDisplayFormatted),
                  ],
                ),
              ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Adjusted height calculation
      height:
          _isSearchExpanded
              ? (_showLocationField
                  ? 140
                  : 70) // If expanded, height depends on location field visibility
              : 70, // If not expanded, always a compact height
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use min to wrap content
        children: [
          // Main search row
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Search icon with rotation animation
                AnimatedRotation(
                  turns: _isSearchExpanded ? 0.125 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.search, color: Colors.blue),
                ),
                const SizedBox(width: 12),

                // Expanding text field
                Expanded(
                  child: TextField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      hintText: "What are you looking for?",
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      setState(() => _isSearchExpanded = true);
                    },
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),

                // Location toggle button
                InkWell(
                  onTap: () {
                    setState(() {
                      _showLocationField = !_showLocationField;
                      // Ensure search bar expands if location field is shown
                      if (_showLocationField) {
                        _isSearchExpanded = true;
                      }
                    });
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _showLocationField
                            ? const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 28,
                              key: ValueKey(1),
                            )
                            : const Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                              size: 28,
                              key: ValueKey(2),
                            ),
                  ),
                ),

                // Animated search button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width:
                      _isSearchExpanded
                          ? 100
                          : 0, // Show button only when expanded
                  child:
                      _isSearchExpanded // Conditionally render the button to avoid overflow during transition
                          ? ElevatedButton(
                            onPressed: _performSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF094497),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Search",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                          : const SizedBox.shrink(), // Hide button when not expanded
                ),
              ],
            ),
          ),

          // Location field (slides in)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child:
                _showLocationField
                    ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pin_drop, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _localityController,
                              decoration: const InputDecoration(
                                hintText: "Enter location (optional)",
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _performSearch(),
                            ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
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
    final products =
        Provider.of<HomeProductController>(
          context,
          listen: false,
        ).products.where((product) => product.shop.id == shop.id).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: 220,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.black.withOpacity(0.4),
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
          Padding(
            padding: const EdgeInsets.only(top: 240),
            child:
                products.isEmpty
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
                                builder:
                                    (context) => ProductDetailsScreen(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color: Colors.green,
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
