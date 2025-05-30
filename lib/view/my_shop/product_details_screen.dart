import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/my_shop_list_user_controller.dart';
import 'package:poketstore/view/home/widgets/product_details_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyShopProductDetails extends StatefulWidget {
  final String productId;

  const MyShopProductDetails({super.key, required this.productId});

  @override
  State<MyShopProductDetails> createState() => _MyShopProductDetailsState();
}

class _MyShopProductDetailsState extends State<MyShopProductDetails> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .fetchProduct(widget.productId);
    });
    super.initState();
  }

  List<Map<String, dynamic>> _allProductsWithShopName = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String? _userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditDialog(context, widget.productId),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, widget.productId),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          log(
            "Provider state - isLoading: ${provider.isLoading}, product: ${provider.product}",
          );

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
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(product.productImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Title & Favorite
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

                // Type
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${product.productType}, Price',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                // Qty & Price
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
                          const Text(
                            'Qty : ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

                // Product Detail
                buildExpandableSection('Product Detail'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    product.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const Divider(thickness: 1, color: Colors.grey),

                // Delivery Info & Other Details
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
    final product =
        Provider.of<ProductProvider>(context, listen: false).product;
    if (product == null) return;

    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(
      text: product.description,
    );
    final priceController = TextEditingController(
      text: product.price.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              final updatedData = {
                "name": nameController.text.trim(),
                "description": descriptionController.text.trim(),
                "price": int.tryParse(priceController.text.trim()) ?? 0,
              };

              Provider.of<ProductProvider>(context, listen: false)
                  .updateProduct(productId, updatedData, context)
                  .then((success) {
                if (success) Navigator.pop(context);
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
      builder: (context) => AlertDialog(
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
            // onPressed: () {
            //   Provider.of<ProductProvider>(context, listen: false).deleteProduct(productId).then((_) => Navigator.pop(context));
            // },
            onPressed: () async {
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              final shopProvider =
                  Provider.of<MyShopListUserProvider>(context, listen: false);

              await productProvider.deleteProduct(productId);
              final prefs = await SharedPreferences.getInstance();
              _userId = prefs.getString('userId');
              shopProvider.fetchUserShopList(_userId!);
              shopProvider.allProductsWithShopName.clear();
              Navigator.pop(context);
            },

            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
