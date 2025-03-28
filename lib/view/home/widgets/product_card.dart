import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String weight;
  final String price;
  final IconData? icon;
  // final String id;

  const ProductCard({
    Key? key,
    required this.imagePath,
    // required this.id,
    required this.title,
    required this.weight,
    required this.price,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 200,
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align items to start
            children: [
              Container(
                height: 60,
                width: 130,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(imagePath)),
                ),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(weight),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(icon, color: Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
