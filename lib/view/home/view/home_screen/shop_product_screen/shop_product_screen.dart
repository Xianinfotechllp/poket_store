import 'package:flutter/material.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:provider/provider.dart';

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
                shop.shopName ?? '',
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
