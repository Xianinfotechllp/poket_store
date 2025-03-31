import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/view/home/widgets/product_card.dart';
import 'package:poketstore/view/my_shop/product_details_screen.dart';
import 'package:provider/provider.dart';

class MyShopeItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const MyShopeItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.close, color: Colors.grey),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CachedNetworkImage(
                //   imageUrl:
                //       item["productImage"] ??
                //       "https://via.placeholder.com/150", // Default placeholder
                //   width: 70,
                //   height: 80,
                //   fit: BoxFit.cover,
                //   placeholder:
                //       (context, url) =>
                //           const CircularProgressIndicator(), // Loading indicator
                //   errorWidget:
                //       (context, url, error) => Image.asset(
                //         'assets/default_image.png', // Local fallback image
                //         width: 70,
                //         height: 80,
                //         fit: BoxFit.cover,
                //       ),
                // ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        ' Rs :${item["price"].toString()}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        ' qty :${item["quantity"].toString()}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      // Row(
                      //   children: [
                      //     // item["quantity"],
                      //     // Container(
                      //     //   decoration: BoxDecoration(
                      //     //     borderRadius: BorderRadius.circular(30),
                      //     //     border: Border.all(color: Colors.grey.shade300),
                      //     //   ),
                      //     //   child: Row(
                      //     //     children: [
                      //     //       IconButton(
                      //     //         onPressed: () {},
                      //     //         icon: Icon(Icons.remove, color: Colors.grey),
                      //     //       ),
                      //     //       Text(
                      //     //         item["quantity"].toString(),
                      //     //         style: TextStyle(
                      //     //           fontSize: 16,
                      //     //           fontWeight: FontWeight.bold,
                      //     //         ),
                      //     //       ),
                      //     //       IconButton(
                      //     //         onPressed: () {},
                      //     //         icon: Icon(Icons.add, color: Colors.green),
                      //     //       ),
                      //     //     ],
                      //     //   ),
                      //     // ),
                      //     Spacer(),
                      //     IconButton(
                      //       onPressed: () {},
                      //       icon: Icon(Icons.movie_edit, color: Colors.green),
                      //     ),
                      //     // Text(
                      //     //   '\$${item["price"].toStringAsFixed(2)}',
                      //     //   style: TextStyle(
                      //     //     fontSize: 16,
                      //     //     fontWeight: FontWeight.bold,
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget productMyShopeGridView(List<Map<String, dynamic>> products) {
  return SizedBox(
    height: 500, // Adjust the height as needed
    child: GridView.builder(
      shrinkWrap: true,
      // physics:
      // NeverScrollableScrollPhysics(), // Prevents grid from scrolling independently if inside another scrollable widget
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75, // Adjust for card proportions
      ),
      itemCount: products.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            String productId = products[index]["_id"].toString();
            log("Tapped Product ID: $productId");
            Provider.of<ProductProvider>(
              context,
              listen: false,
            ).fetchProduct(productId);
            final result = Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MyShopProductDetails(
                      productId: productId,
                      // Pass product ID
                    ),
              ),
            );
            if (result == true) {
              Provider.of<FetchProductProvider>(
                context,
                listen: false,
              ).loadProductsForUser();
            }
          },
          child: ProductCard(
            // id: products[index]["_id"],
            imagePath: products[index]["image"],
            title: products[index]["name"],
            weight: products[index]["weight"],
            price: products[index]["price"],
          ),
        );
      },
    ),
  );
}
