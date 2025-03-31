import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/cart/widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            final cart = cartProvider.cart;
            if (cart == null || cart.items.isEmpty) {
              return Center(child: Text("Your cart is empty"));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'My Cart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      return CartItemWidget(item: cart.items[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: GestureDetector(
                    onTap: () => _showCheckoutPopup(context),
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
                            'Go to Checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //   '\$$',
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
            );
          },
        ),
      ),
    );
  }

  void _showCheckoutPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final cart = cartProvider.cart;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Checkout",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildCheckoutOption("Delivery", "Select Method"),
                            _buildCheckoutOption("Payment", "💳"),
                            _buildCheckoutOption("Promo Code", "Pick discount"),
                            _buildCheckoutOption(
                              "Total Cost",
                              "\$${cart!.items}",
                            ),
                            SizedBox(height: 10),
                            Text(
                              "By placing an order you agree to our Terms And Conditions",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 3, 201),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          // Handle order placement
                        },
                        child: Text(
                          "Place Order",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCheckoutOption(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Text(value, style: TextStyle(fontSize: 16, color: Colors.grey)),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
