import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/controllers/my_shope_controller/my_shop_list_user_controller.dart';
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

Widget productMyShopeGridView(List<Map<String, dynamic>> productsWithShopName) {
  return GridView.builder(
    padding: const EdgeInsets.all(10),
    shrinkWrap: true,
    // physics:
    //     const NeverScrollableScrollPhysics(), // To prevent nested scrolling
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.75, // Adjust as needed for your design
    ),
    itemCount: productsWithShopName.length,
    itemBuilder: (context, index) {
      final product = productsWithShopName[index];
      return GestureDetector(
        onTap: () async {
          String productId = product["_id"].toString();
          log("Tapped Product ID: $productId");
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyShopProductDetails(productId: productId),
            ),
          );
          // if (result == true) {
          //   log("Refreshing My Shop Screen...");
          //   Provider.of<MyShopListUserProvider>(
          //     context,
          //     listen: false,
          //   ).fetchUserShopList(_userId!);
          // }
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        product["image"],
                        height: 100, // Adjust as needed
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product["weight"],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product["price"],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(), // Push shop name to the bottom
                Text(
                  "Shop: ${product["shopName"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
