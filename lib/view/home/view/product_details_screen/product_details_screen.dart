import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/favorite_controller/favorite_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProduct(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.product == null) {
            return const Center(child: Text('No product found'));
          }

          final product = provider.product!;
          log("Product fetched: ${product.name}, ID: ${widget.productId}");

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(product.productImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Product Title & Favorite Icon
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.grey),
                        onPressed: () {
                          // Add your favourite logic here
                          log("Added to favourite: ${product.name}");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${product.name} added to Favourites')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Weight & Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${product.productType}, Price',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                // Quantity & Price Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Qty :',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            product.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(thickness: 1, color: Colors.grey),

                // Product Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    product.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const Divider(thickness: 1, color: Colors.grey),

                // Delivery Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRowWithArrow(
                          'Estimated Delivery', product.estimatedTime),
                      _buildRowWithArrow(
                          'Category', product.category.toString()),
                      _buildRowWithArrow('Product Type', product.productType),
                      _buildRowWithArrow(
                          'Delivery Option', product.deliveryOption),
                    ],
                  ),
                ),

                const Divider(thickness: 1, color: Colors.grey),

                // Add to Favourite Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      final favProvider =
                          Provider.of<FavoriteProvider>(context, listen: false);

                      log("Clicked Add to Favourite for Product ID: ${product.id}"); // Log product ID

                      await favProvider.addToFavorite(
                          product.id); // Ensure product.id is correct

                      if (favProvider.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${product.name} added to Favourites'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Already added to Favourites'),
                          ),
                        );
                      }
                    },
                    child: const Center(
                      child: Text(
                        'Add To Favourite',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRowWithArrow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
