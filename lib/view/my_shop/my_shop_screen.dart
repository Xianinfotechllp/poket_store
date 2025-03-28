import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/view/my_shop/add_product_screen.dart';
import 'package:poketstore/view/my_shop/widget.dart';
import 'package:provider/provider.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<FetchProductProvider>(
            context,
            listen: false,
          ).loadProductsForUser(),
    );
  }

  Future<void> _refreshProducts() async {
    await Provider.of<FetchProductProvider>(
      context,
      listen: false,
    ).loadProductsForUser();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search Products...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProducts,
                child: Consumer<FetchProductProvider>(
                  builder: (context, productProvider, child) {
                    if (productProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (productProvider.errorMessage.isNotEmpty) {
                      return Center(child: Text(productProvider.errorMessage));
                    } else if (productProvider.products.isEmpty) {
                      return const Center(child: Text("No products available"));
                    }

                    // Filter products based on search query
                    final filteredProducts =
                        productProvider.products.where((product) {
                          return product.name.toLowerCase().contains(
                            _searchQuery,
                          );
                        }).toList();

                    return productMyShopeGridView(
                      filteredProducts.map((product) {
                        return {
                          "_id": product.id,
                          "image": product.productImage,
                          "name": product.name,
                          "weight": product.productType,
                          "price": "₹${product.price}",
                        };
                      }).toList(),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _refreshProducts();
                    }
                  });
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
