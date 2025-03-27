import 'package:flutter/material.dart';
import 'package:poketstore/view/home/widgets/product_details_widget.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            //   IconButton(
            //     icon: Icon(Icons.share, color: Colors.black),
            //     onPressed: () {},
            //   ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Product Image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/productdetails.png'),
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
                      'Naturel Red Apple',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.favorite_border, color: Colors.grey),
                  ],
                ),
              ),

              /// Weight & Price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('1kg, Price', style: TextStyle(color: Colors.grey)),
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
                    /// Quantity Selector
                    Row(
                      children: [
                        buildQuantityButton(Icons.remove),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        buildQuantityButton(Icons.add),
                      ],
                    ),

                    /// Price
                    Text(
                      '\$4.99',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(thickness: 1, color: Colors.grey.shade300),

              /// Product Details
              buildExpandableSection('Product Detail', Icons.arrow_drop_down),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Apples are nutritious. Apples may be good for weight loss.\n'
                  'Apples may be good for your heart. As part of a healthy\n'
                  'and varied diet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              Divider(thickness: 1, color: Colors.grey.shade300),

              /// Nutritions
              buildRowWithArrow('Nutritions', '100g'),

              Divider(thickness: 1, color: Colors.grey.shade300),

              /// Reviews
              buildRowWithStars('Review', 5),

              /// Add to Cart Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: Center(
                    child: Text(
                      'Add To Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
