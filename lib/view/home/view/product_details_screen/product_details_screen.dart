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
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        title: const Text(
          "Product Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                SizedBox(height: 30),
                // Product Image
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(product.productImage),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Product Title & Favorite Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Consumer<FavoriteProvider>(
                        builder: (context, favProvider, _) {
                          final isFavorite = favProvider.favorites.any(
                            (favProduct) => favProduct.id == product.id,
                          );
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 30,
                            ),
                            onPressed: () async {
                              log(
                                "Clicked Add to Favourite for Product ID: ${product.id}",
                              );

                              if (isFavorite) {
                                // If already favorite, remove it
                                await favProvider.removeFromFavorite(
                                  product.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.name} removed from Favourites',
                                    ),
                                  ),
                                );
                              } else {
                                // If not favorite, add it
                                await favProvider.addToFavorite(product.id);
                                if (favProvider.isSuccess) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} added to Favourites',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to add to Favourites',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Product Type & Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.productType,
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                      Text(
                        '\₹${product.price.toStringAsFixed(2)}', // Format price to 2 decimal places
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green, // Highlight price
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quantity Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        product.quantity.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(
                  thickness: 1,
                  color: Colors.black12,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 10),

                // Product Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(
                  thickness: 1,
                  color: Colors.black12,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 10),

                // Delivery Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        'Estimated Delivery',
                        product.estimatedTime,
                        Icons.access_time,
                      ),
                      _buildInfoRow(
                        'Category',
                        product.category.toString(),
                        Icons.category,
                      ),
                      _buildInfoRow(
                        'Product Type',
                        product.productType,
                        Icons.local_mall,
                      ),
                      _buildInfoRow(
                        'Delivery Option',
                        product.deliveryOption,
                        Icons.delivery_dining,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Add to Favourite Button (Keeping for now, consider changing to Add to Cart)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 7, 3, 201),
                          Color.fromARGB(255, 50, 46, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            7,
                            3,
                            201,
                          ).withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors
                                .transparent, // Make button transparent to show gradient
                        shadowColor:
                            Colors.transparent, // Remove shadow from button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () async {
                        final favProvider = Provider.of<FavoriteProvider>(
                          context,
                          listen: false,
                        );

                        log(
                          "Clicked Add to Favourite for Product ID: ${product.id}",
                        );

                        // Toggle favorite status
                        final isFavorite = favProvider.favorites.any(
                          (favProduct) => favProduct.id == product.id,
                        );

                        if (isFavorite) {
                          await favProvider.removeFromFavorite(product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} removed from Favourites',
                              ),
                            ),
                          );
                        } else {
                          await favProvider.addToFavorite(product.id);
                          if (favProvider.isSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} added to Favourites',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to add to Favourites or already added',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Center(
                        child: Text(
                          'Add To Favourite',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
