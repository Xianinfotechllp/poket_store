import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/fetch_cart_controller.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/controllers/order_controller/order_controller.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:poketstore/model/cart_model/fetch_cart_model.dart';
import 'package:poketstore/model/order_model/order_model.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/view/delivery_address/delivery_address.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final ProductModel product;
  final int initialQuantity;
  final String cartItemId;

  const CheckoutBottomSheet({
    super.key,
    required this.product,
    required this.initialQuantity,
    required this.cartItemId,
  });

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  late int _quantity;
  Address? _selectedDeliveryAddress;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increaseQuantity() {
    setState(() => _quantity++);
    _updateCartQuantity();
    Fluttertoast.showToast(
      msg: "Quantity increased for ${widget.product.name}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
      _updateCartQuantity();
      Fluttertoast.showToast(
        msg: "Quantity decreased for ${widget.product.name}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Quantity cannot be less than 1.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _updateCartQuantity() {
    Provider.of<FetchCartController>(
      context,
      listen: false,
    ).updateQuantity(widget.product.id, _quantity);
  }

  void _selectAddress() async {
    final selectedAddressId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 40, top: 16, left: 16, right: 16),
            child: DeliveryAddressBottomSheet(),
          ),
    );

    if (selectedAddressId != null) {
      final controller = Provider.of<DeliveryAddressController>(
        context,
        listen: false,
      );
      final address = controller.addresses.firstWhere(
        (addr) => addr.id == selectedAddressId,
        orElse:
            () =>
                throw Exception("Address with ID $selectedAddressId not found"),
      );

      setState(() => _selectedDeliveryAddress = address);

      Fluttertoast.showToast(
        msg: "Address selected: ${address.area}, ${address.town}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "No new address was selected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() => _selectedDeliveryAddress = null);
    }
  }

  String _getFormattedAddress(Address? address) {
    if (address == null) return "No address selected.";
    final parts = <String>[];
    if (address.houseNo != null && address.houseNo!.isNotEmpty)
      parts.add(address.houseNo!);
    if (address.area != null && address.area!.isNotEmpty)
      parts.add(address.area!);
    if (address.landmark != null && address.landmark!.isNotEmpty)
      parts.add(address.landmark!);
    parts.add(address.town ?? '');
    parts.add(address.state ?? '');
    parts.add(address.pincode ?? '');
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final totalProductPrice = _quantity * widget.product.price;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.productImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Unit Price: ₹${widget.product.price}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quantity:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.deepPurple),
                      onPressed: _decreaseQuantity,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.deepPurple),
                      onPressed: _increaseQuantity,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Price:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹$totalProductPrice",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delivery Address:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedDeliveryAddress == null
                            ? "Please select an address."
                            : _getFormattedAddress(_selectedDeliveryAddress),
                        style: TextStyle(
                          color:
                              _selectedDeliveryAddress == null
                                  ? Colors.red
                                  : Colors.black87,
                          fontStyle:
                              _selectedDeliveryAddress == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _selectAddress,
                  child: Text(
                    _selectedDeliveryAddress == null ? "Select" : "Change",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _selectedDeliveryAddress != null
                      ? () async {
                        final orderController = Provider.of<OrderController>(
                          context,
                          listen: false,
                        );

                        final orderItems = [
                          OrderItem(
                            productId: widget.product.id,
                            quantity: _quantity,
                          ),
                        ];

                        final addressId = _selectedDeliveryAddress!.id;

                        log(
                          "Placing order for product: ${widget.product.id} to address: $addressId",
                        );

                        try {
                          await orderController.submitOrder(
                            orderItems,
                            addressId.toString(),
                          );

                          final response = orderController.orderResponse;

                          // --- MODIFIED LOGIC HERE ---
                          // Check if the message indicates success. This is a workaround
                          // if the 'success' boolean field is truly missing or always false.
                          bool isSuccessBasedOnMessage =
                              response?.message?.toLowerCase().contains(
                                'success',
                              ) ??
                              false;

                          if (response != null && isSuccessBasedOnMessage) {
                            Fluttertoast.showToast(
                              msg: response.message,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            Provider.of<FetchCartController>(
                              context,
                              listen: false,
                            ).fetchCart();
                            Navigator.pop(context);
                          } else {
                            // Default failure message, or use backend message if it doesn't contain 'success'
                            String failureMessage =
                                "Order failed. Please try again.";
                            if (response != null &&
                                response.message != null &&
                                response.message.isNotEmpty) {
                              if (!isSuccessBasedOnMessage) {
                                // Use original message only if it's not a success message
                                failureMessage = response.message;
                              }
                            }
                            Fluttertoast.showToast(
                              msg: failureMessage,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          log("Error submitting order: $e");
                          Fluttertoast.showToast(
                            msg: "Network error. Please check your connection.",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          Navigator.pop(context);
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Proceed to Checkout",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
