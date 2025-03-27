import 'package:flutter/material.dart';
import 'package:poketstore/view/favourite/widgets.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cartItems = const [
      {
        "name": "Sprite can",
        "image": "assets/favorite.png",
        // "quantity": 1,
        "price": 4.99,
      },
      {
        "name": "Sprite can",
        "image": "assets/image.png",
        // "quantity": 2,
        "price": 3.49,
      },
      {
        "name": "Sprite can",
        "image": "assets/favorite.png",
        // "quantity": 1,
        "price": 4.99,
      },
      {
        "name": "Bell Pepper Red",
        "image": "assets/image.png",
        // "quantity": 1,
        "price": 4.99,
      },
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Favourite',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return FavouritItemWidget(item: cartItems[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 7, 3, 201),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Add All To Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //   '\$12.96',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
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
