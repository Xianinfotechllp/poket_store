import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/fcm_controller/fcm_controller.dart';
import 'package:poketstore/controllers/groceries_list_controller/groceries_list_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart';
import 'package:poketstore/controllers/product_search_controller/product_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/shop_search_controller.dart';
import 'package:poketstore/controllers/shop_nearby_controller/shop_nearby_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/utilities/search_bar.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/home/view/home_screen/shop_product_screen/shop_product_screen.dart';
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

// Import the new SearchBarWidget // Adjust path as needed

// ... [All your existing imports]
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';

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
  final TextEditingController _shopNameController = TextEditingController();
  late LocationMapController _locationMapController;
  late HomeProductController _homeProductController;
  late ProductSearchProvider _productSearchProvider;
  late ShopSearchController _shopSearchController;
  bool _isDataLoaded = false;
  bool _isSearchBarExpanded = false;

  final List<String> _bannerImages = [
    'assets/slider.png',
    'assets/slider.png',
    'assets/slider.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FCMProvider>(
        context,
        listen: false,
      ).registerFcmToken(context);
    });
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
      _shopSearchController = Provider.of<ShopSearchController>(
        context,
        listen: false,
      );
      _loadInitialData();
      _isDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _localityController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialErrorMessage = null;
    });
    try {
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
        Provider.of<ShopNearbyController>(
          context,
          listen: false,
        ).loadNearbyShops(),
      ]);
    } catch (error) {
      setState(() {
        _initialErrorMessage = "Failed to load initial data: $error";
      });
    } finally {
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  void _performSearch() {
    final productName = _productNameController.text.trim();
    final locality = _localityController.text.trim();
    final shopName = _shopNameController.text.trim();

    _productSearchProvider.fetchSearchResults(productName, locality);
    if (shopName.isNotEmpty) {
      _shopSearchController.searchShopsWithPrefs(shopName);
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

  void _onSearchBarExpansionChanged(bool isExpanded) {
    setState(() {
      _isSearchBarExpanded = isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopNearbyController = Provider.of<ShopNearbyController>(context);
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

    // ✅ Display all shops
    List<ShopModel> allShops = shopProvider.shops;
    final displayedStores =
        _showAllStores ? allShops : allShops.take(3).toList();

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
                    SearchBarWidget(
                      productNameController: _productNameController,
                      localityController: _localityController,
                      shopNameController: _shopNameController,
                      onSearch: _performSearch,
                      onSearchExpanded: _onSearchBarExpansionChanged,
                    ),
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
                      () => setState(() => _showAllStores = !_showAllStores),
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
                              // You might need to convert ShopNearbyModel to ShopModel if ShopProductsScreen needs that.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ShopProductsScreen(
                                        shop: ShopModel(
                                          id: shop.id,
                                          shopName: shop.shopName,
                                          // add other required fields if needed
                                        ),
                                      ),
                                ),
                              );
                            },
                            child: buildStoreItem(
                              shop.shopName ?? '',
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
                    else ...[
                      buildSectionTitle("Products", "", () {}),
                      productGridView(productsToDisplayFormatted),
                    ],
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
}
