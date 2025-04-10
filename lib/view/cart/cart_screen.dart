import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/fetch_cart_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/cart/widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<FetchCartProvider>(context, listen: false);

    return FutureBuilder(
      future: cartProvider.fetchCart(), // Important!
      builder: (context, snapshot) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Consumer<FetchCartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cartData = cartProvider.cartData;
                if (cartData == null || cartData.cart.items.isEmpty) {
                  return const Center(child: Text("Your cart is empty"));
                }

                final cart = cartData.cart;

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'My Cart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
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
                          child: const Row(
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
      },
    );
  }
}

void _showCheckoutPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Consumer<FetchCartProvider>(
        builder: (context, cartProvider, child) {
          final cartData = cartProvider.cartData;
          final cart = cartData?.cart;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildCheckoutOption("Delivery", "Select Method"),
                          _buildCheckoutOption("Payment", "💳"),
                          _buildCheckoutOption("Promo Code", "Pick discount"),
                          // _buildCheckoutOption(
                          //   "Total Cost",
                          //   "\$${cart?.totalCost.toStringAsFixed(2) ?? '0.00'}",
                          // ),
                          const SizedBox(height: 10),
                          const Text(
                            "By placing an order you agree to our Terms And Conditions",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        // Handle order placement
                      },
                      child: const Text(
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ],
    ),
  );
}
