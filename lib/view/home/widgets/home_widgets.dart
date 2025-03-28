import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:poketstore/view/home/widgets/product_card.dart';
import 'package:provider/provider.dart';

Widget buildSectionTitle(String title, String action) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
      ],
    ),
  );
}

Widget groceriesHorizontalList(List<Map<String, dynamic>> items) {
  return SizedBox(
    height: 80,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return buildGroceryItem(items[index]["name"], items[index]["color"]);
      },
    ),
  );
}

Widget buildGroceryItem(String name, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 10),
    height: 100,
    width: 250,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/groceries.png'),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    ),
  );
}

Widget storeHorizontalList(List<Map<String, dynamic>> items) {
  return SizedBox(
    height: 80,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return buildStoreItem(items[index]["name"], items[index]["color"]);
      },
    ),
  );
}

Widget buildStoreItem(String name, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 10),
    height: 100,
    width: 250,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/groceries.png'),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    ),
  );
}

Widget productGridView(List<Map<String, dynamic>> products) {
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
          onTap: () {
            String productId = products[index]["_id"].toString();
            log("Tapped Product ID: $productId");
            Provider.of<ProductProvider>(
              context,
              listen: false,
            ).fetchProduct(productId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetailsScreen(
                      productId: productId, // Pass product ID
                    ),
              ),
            );
          },
          child: ProductCard(
            // id: products[index]["_id"],
            icon: Icons.shopping_cart_outlined,
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
