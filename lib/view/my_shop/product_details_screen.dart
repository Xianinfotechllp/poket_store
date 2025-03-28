import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/view/home/widgets/product_details_widget.dart';
import 'package:provider/provider.dart';

class MyShopProductDetails extends StatelessWidget {
  final String productId;
  const MyShopProductDetails({super.key, required this.productId});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              _showEditDialog(context, productId);
              // Navigator.pushNamed(
              //   context,
              //   '/editProductScreen', // Change to your actual edit screen route
              //   arguments: productId,
              // );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _confirmDelete(context, productId);
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          log(
            "ProductDetailsScreen: Provider state - isLoading: ${provider.isLoading}, product: ${provider.product}",
          );

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.product == null) {
            return const Center(child: Text('No product found'));
          }

          final product = provider.product!;
          log("Product fetched successfully: ${product.name}, ID: $productId");

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product Image
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

                /// Product Title & Favorite Icon
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
                      const Icon(Icons.favorite_border, color: Colors.grey),
                    ],
                  ),
                ),

                /// Weight & Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${product.productType}, Price',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                /// Quantity & Price Section
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

                      // Price
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

                // Product Details
                buildExpandableSection('Product Detail'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    product.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const Divider(thickness: 1, color: Colors.grey),

                /// Delivery Info
                buildRowWithArrow('Estimated Delivery', product.estimatedTime),
                const Divider(thickness: 1, color: Colors.grey),
                buildRowWithArrow('Category', product.category.toString()),
                const Divider(thickness: 1, color: Colors.grey),
                buildRowWithArrow('Product Type', product.productType),
                const Divider(thickness: 1, color: Colors.grey),
                buildRowWithArrow('Delivery Option', product.deliveryOption),
                const Divider(thickness: 1, color: Colors.grey),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String productId) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Product"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final Map<String, dynamic> updatedData = {
                    "name": nameController.text,
                    "description": descriptionController.text,
                    "price": int.tryParse(priceController.text) ?? 0,
                  };

                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).updateProduct(productId, updatedData).then((success) {
                    if (success) {
                      Navigator.pop(context, true);
                    }
                  });
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Product"),
            content: const Text(
              "Are you sure you want to delete this product?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).deleteProduct(productId).then((_) {
                    Navigator.pop(context, true);
                  });
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }
}
