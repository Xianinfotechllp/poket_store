// Updated and beautified version of ProductDetailsScreen
// Focus: clean layout, modern design, and better visual consistency

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/controllers/favorite_controller/favorite_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
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
      context.read<ProductProvider>().fetchProduct(widget.productId);
      context.read<CartController>().fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(title: 'ProductDetails', showBackButton: true),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = provider.product;
          if (product == null) {
            return const Center(child: Text('No product found'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      product.productImage,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name and favorite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Consumer<FavoriteProvider>(
                        builder: (context, favProvider, _) {
                          final isFav = favProvider.favorites.any(
                            (f) => f.id == product.id,
                          );
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              if (isFav) {
                                await favProvider.removeFromFavorite(
                                  product.id,
                                );
                              } else {
                                await favProvider.addToFavorite(product.id);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Product type and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(label: Text(product.productType)),
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quantity
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(product.quantity.toString()),
                    ],
                  ),

                  const Divider(height: 30),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.justify,
                  ),

                  const Divider(height: 30),

                  // Delivery Info
                  const Text(
                    'Delivery Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    Icons.shopping_bag,
                  ),
                  _buildInfoRow(
                    'Delivery Option',
                    product.deliveryOption,
                    Icons.delivery_dining,
                  ),

                  const SizedBox(height: 30),

                  // Add to Cart
                  Consumer<CartController>(
                    builder: (context, cartController, _) {
                      final inCart = cartController.isProductInCart(product.id);
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                inCart
                                    ? Colors.grey
                                    : Color.fromARGB(255, 7, 3, 201),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              inCart
                                  ? null
                                  : () async {
                                    final added = await cartController
                                        .addProductToCart(product.id, 1);
                                    final msg =
                                        added
                                            ? 'Added to cart'
                                            : 'Already in cart';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  },
                          child:
                              cartController.isAdding
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    inCart ? 'Already in Cart' : 'Add to Cart',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
