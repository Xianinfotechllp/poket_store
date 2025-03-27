import 'package:flutter/material.dart';
import 'package:poketstore/view/my_shop/add_product_screen.dart';
import 'package:poketstore/view/my_shop/widget.dart';

class MyShopScreen extends StatelessWidget {
  const MyShopScreen({super.key});

  final List<Map<String, dynamic>> cartItems = const [
    {
      "name": "Bell Pepper Red",
      "image": "assets/product1.png",
      "quantity": 1,
      "price": 4.99,
    },
    {
      "name": "Green Apple",
      "image": "assets/product1.png",
      "quantity": 2,
      "price": 3.49,
    },
    {
      "name": "Bell Pepper Red",
      "image": "assets/product1.png",
      "quantity": 1,
      "price": 4.99,
    },
    {
      "name": "Bell Pepper Red",
      "image": "assets/product1.png",
      "quantity": 1,
      "price": 4.99,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage('assets/myshope.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 130,
                  child: Text(
                    "My Shop",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return MyShopeItemWidget(item: cartItems[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen()),
                  );
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 7, 3, 201),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.add, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
