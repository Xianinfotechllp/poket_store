import 'package:flutter/material.dart';
import 'package:poketstore/view/home/widgets/product_card.dart';

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

Widget productHorizontalList(List<Map<String, dynamic>> products) {
  return SizedBox(
    height: 220,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return ProductCard(
          imagePath: products[index]["image"],
          title: products[index]["name"],
          weight: products[index]["weight"],
          price: products[index]["price"],
        );
      },
    ),
  );
}
