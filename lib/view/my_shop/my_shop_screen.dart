import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/my_shop_list_user_controller.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/my_shop/add_product_screen.dart';
import 'package:poketstore/view/my_shop/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  late MyShopListUserProvider _controller;
  String? _userId;
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    log("🛠️ MyShopScreen initialized");
    _controller = MyShopListUserProvider();
    _loadUserIdAndShops();
  }

  Future<void> _loadUserIdAndShops() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    log(
      "🔑 Retrieved userId from SharedPreferences in _loadUserIdAndShops: $_userId",
    );
    if (_userId != null) {
      log("🔑 User ID retrieved from SharedPreferences: $_userId");
      await _loadUserShops(); // Await the loading of shops
    } else {
      log("⚠️ User ID not found in SharedPreferences.");
      setState(() {
        _isLoading = false; // Set loading to false if no user ID
      });
    }
  }

  Future<void> _loadUserShops() async {
    if (_userId != null) {
      log("📦 Loading user shops for user ID: $_userId");
      await Provider.of<MyShopListUserProvider>(
        context,
        listen: false,
      ).fetchUserShopList(_userId!);
    } else {
      log("🛑 Cannot load shops, user ID is null.");
    }
    setState(() {
      _isLoading = false; // Set loading to false after attempting to load shops
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:
            _isLoading // Check the loading state
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // Show loader
                : Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/myshope.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 100,
                          left: 130,
                          child: Text(
                            "My Shop",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Consumer<MyShopListUserProvider>(
                        builder: (context, provider, child) {
                          if (_userId == null) {
                            return const Center(
                              child: Text("Please log in to view your shops."),
                            );
                          }
                          if (provider.isLoading) {
                            log("🔄 Shop list is loading...");
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (provider.error != null) {
                            log("❌ Error loading shops: ${provider.error}");
                            return Center(child: Text(provider.error!));
                          } else if (provider.shopList.isEmpty) {
                            log("📭 No shops available for this user.");
                            return const Center(
                              child: Text("No shops available"),
                            );
                          }

                          List<Map<String, dynamic>> allProductsWithShopName =
                              [];
                          for (var shop in provider.shopList) {
                            if (shop.products != null) {
                              for (var product in shop.products!) {
                                allProductsWithShopName.add({
                                  "_id": product.id ?? "",
                                  "image":
                                      (product.productImage != null &&
                                              product.productImage!.isNotEmpty)
                                          ? product.productImage
                                          : "https://via.placeholder.com/150",
                                  "name": product.name ?? "Unknown",
                                  "weight": product.productType ?? "N/A",
                                  "price":
                                      "₹${(product.price != null && product.price! > 0) ? product.price : 'N/A'}",
                                  "shopName":
                                      shop.shopName ??
                                      "Unnamed Shop", // Add shop name
                                });
                              }
                            }
                          }

                          log(
                            "🛒 Total products with shop name found: ${allProductsWithShopName.length}",
                          );

                          if (allProductsWithShopName.isEmpty) {
                            return const Center(
                              child: Text("No products added yet."),
                            );
                          }

                          return productMyShopeGridView(
                            allProductsWithShopName,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: GestureDetector(
                        onTap: () {
                          log("➕ Add Product button tapped");
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.info,
                                        size: 50,
                                        color: Colors.blueAccent,
                                      ),
                                      const SizedBox(height: 15),
                                      const Text(
                                        "Notice",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "If you have a store, continue adding a product.\nOtherwise, create one by clicking 'Create'.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                backgroundColor:
                                                    Colors.grey[300],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                log("❌ Cancel clicked");
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                log(
                                                  "🛍️ Continue to AddProductScreen",
                                                );
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const AddProductScreen(),
                                                  ),
                                                ).then((value) {
                                                  if (value == true) {
                                                    log(
                                                      "🔁 Product added, reloading shops...",
                                                    );
                                                    _loadUserShops();
                                                  }
                                                });
                                              },
                                              child: const Text("Continue"),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                log(
                                                  "🏪 Navigating to AddShop screen",
                                                );
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const AddShop(),
                                                  ),
                                                );
                                              },
                                              child: const Text("Create"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 7, 3, 201),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Add Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.add, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
