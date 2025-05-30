// poketstore/view/delivery_address/delivery_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/view/delivery_address/add_address.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch addresses when the screen initializes
    _fetchAddresses();
  }

  // Helper function to fetch addresses
  Future<void> _fetchAddresses() async {
    await Provider.of<AddressController>(context, listen: false).getAddresses();
  }

  // Helper function to navigate to AddAddressPage and handle result
  void _navigateToAddEditAddress({AddressModel? address}) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAddressPage(address: address)),
    );

    // If result is true, it means an address was successfully added or updated
    if (result == true) {
      log("Address operation successful, refreshing list...");
      _fetchAddresses(); // Re-fetch addresses to update the list
    }
  }

  // Helper function for delete confirmation and action
  void _confirmAndDeleteAddress(
      AddressModel address, AddressController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Dismiss the dialog first
              await controller.deleteAddress(address.id!);
              if (controller.errorMessage.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address deleted successfully')),
                );
                _fetchAddresses(); // Re-fetch addresses to update the list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Error deleting address: ${controller.errorMessage}')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressController>(
      builder: (context, addressController, child) {
        if (addressController.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (addressController.addresses.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Delivery Addresses'),
            ),
            body: const Center(
              child: Text("No delivery addresses found. Add an address."),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _navigateToAddEditAddress(), // Use the helper
              label: const Text("Add Address",
                  style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: const Color(0xFF094497),
              elevation: 4,
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Delivery Addresses'),
            ),
            body: ListView.builder(
              itemCount: addressController.addresses.length,
              itemBuilder: (context, index) {
                final AddressModel address = addressController.addresses[index];
                return _buildAddressCard(address, addressController, context);
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _navigateToAddEditAddress(), // Use the helper
              label: const Text("Add Address",
                  style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: const Color(0xFF094497),
              elevation: 4,
            ),
          );
        }
      },
    );
  }

  Widget _buildAddressCard(AddressModel address,
      AddressController addressController, BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Country: ${address.countryName}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Phone: ${address.phoneNumber}'),
                      Text('House No: ${address.houseNo}'),
                      Text('Area: ${address.area}'),
                      Text('Landmark: ${address.landmark}'),
                      Text('Pincode: ${address.pincode}'),
                      Text('Town: ${address.town}'),
                      Text('State: ${address.state}'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        log("Editing address with ID: ${address.id}");
                        _navigateToAddEditAddress(
                            address: address); // Use the helper
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        log("Attempting to delete address with ID: ${address.id}");
                        _confirmAndDeleteAddress(
                            address, addressController); // Use the helper
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
