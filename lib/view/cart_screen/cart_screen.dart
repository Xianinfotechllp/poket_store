import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/fetch_cart_controller.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart'; // Import this
import 'package:poketstore/controllers/order_controller/order_controller.dart'; // Import this
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/model/order_model/order_model.dart'; // Import this
import 'package:poketstore/utilities/checkout_bottom_sheet.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/view/delivery_address/delivery_address.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure addresses are fetched when cart screen loads,
    // as we might need them for the "Purchase All" functionality.
    Provider.of<DeliveryAddressController>(
      context,
      listen: false,
    ).fetchAddresses();
    Provider.of<FetchCartController>(context, listen: false).fetchCart();
  }

  // Function to handle purchasing all items in the cart
  void _purchaseAllItems() async {
    final fetchCartController = Provider.of<FetchCartController>(
      context,
      listen: false,
    );
    final orderController = Provider.of<OrderController>(
      context,
      listen: false,
    );
    final addressController = Provider.of<DeliveryAddressController>(
      context,
      listen: false,
    );

    if (fetchCartController.cart == null ||
        fetchCartController.cart!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty. Nothing to purchase."),
        ),
      );
      return;
    }

    // Prompt user to select an address if none is selected or a default is not set
    Address? selectedAddress;
    if (addressController.addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a delivery address first.")),
      );
      // Optionally navigate to add address screen or show address selection bottom sheet
      final result = await showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder:
            (_) => const Padding(
              padding: EdgeInsets.only(
                bottom: 40,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: DeliveryAddressBottomSheet(),
            ),
      );
      if (result != null) {
        selectedAddress = addressController.addresses.firstWhere(
          (addr) => addr.id == result,
          orElse: () => throw Exception("Address with ID $result not found"),
        );
      } else {
        // User cancelled address selection
        return;
      }
    } else {
      // For simplicity, we'll assume the first address is the default or user will select it.
      // In a real app, you'd likely have a mechanism for a default address or prompt for selection.
      // For now, let's open the address selection if there are addresses
      final result = await showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder:
            (_) => const Padding(
              padding: EdgeInsets.only(
                bottom: 40,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: DeliveryAddressBottomSheet(),
            ),
      );
      if (result != null) {
        selectedAddress = addressController.addresses.firstWhere(
          (addr) => addr.id == result,
          orElse: () => throw Exception("Address with ID $result not found"),
        );
      } else {
        // User cancelled address selection
        return;
      }
    }

    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a delivery address to proceed."),
        ),
      );
      return;
    }

    // Prepare order items from the cart
    final orderItems =
        fetchCartController.cart!.items.map((cartItem) {
          return OrderItem(
            productId: cartItem.product.id,
            quantity: cartItem.quantity,
          );
        }).toList();

    log("Placing order for all items to address: ${selectedAddress.id}");

    // Submit the order
    await orderController.submitOrder(
      orderItems,
      selectedAddress.id.toString(),
    );

    // Handle order response
    final response = orderController.orderResponse;
    if (response != null && response.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
      // Optionally clear the cart after successful purchase
      // This would require a method in FetchCartController to clear the cart on the backend
      // fetchCartController.clearCart(); // Call this if you implement it
      fetchCartController
          .fetchCart(); // Re-fetch cart to reflect changes (items should be removed from backend)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response?.message ??
                "Order failed for all items. Please try again.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Cart"),
      body: Consumer<FetchCartController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = controller.cart;
          if (cart == null || cart.items.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          // Calculate total price of all items in the cart
          final overallTotalPrice = cart.items.fold<double>(
            0.0,
            (sum, item) => sum + item.totalProductPrice,
          );

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchCart(),
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final product = item.product;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.productImage,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Qty: ${item.quantity} • ₹${item.totalProductPrice}",
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder:
                                        (context) => CheckoutBottomSheet(
                                          product: product,
                                          initialQuantity: item.quantity,
                                          cartItemId: item.id,
                                        ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    7,
                                    3,
                                    201,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Buy", // Changed text for clarity
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹${product.price}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirmDelete = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text("Remove from Cart"),
                                          content: Text(
                                            "Are you sure you want to remove ${product.name} from your cart?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: const Text(
                                                "Remove",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirmDelete == true) {
                                    Provider.of<FetchCartController>(
                                      context,
                                      listen: false,
                                    ).removeItemFromCart(product.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // "Purchase All" Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Overall Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${overallTotalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _purchaseAllItems,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 3, 201),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Purchase All Items",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
