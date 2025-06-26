import 'package:flutter/material.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/view/delivery_address/add_address.dart'; // <-- Ensure this import points to your AddressForm
import 'package:provider/provider.dart';

class DeliveryAddressBottomSheet extends StatefulWidget {
  const DeliveryAddressBottomSheet({super.key});

  @override
  State<DeliveryAddressBottomSheet> createState() =>
      _DeliveryAddressBottomSheetState();
}

class _DeliveryAddressBottomSheetState
    extends State<DeliveryAddressBottomSheet> {
  // Use a String to store the ID of the selected address for the RadioListTile's groupValue
  String? selectedAddressId;
  // Store the full Address object of the currently selected address to pass it back
  Address? currentlySelectedAddress;

  @override
  void initState() {
    super.initState();
    // Fetch addresses after the first frame is rendered to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeliveryAddressController>(
        context,
        listen: false,
      ).fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DeliveryAddressController>(context);

    return Container(
      // Provide a fixed height for the bottom sheet to allow the list to scroll
      height:
          MediaQuery.of(context).size.height *
          0.75, // Take 75% of screen height
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          // mainAxisSize is removed as Expanded child will now fill available space
          children: [
            const Text(
              "Select Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Conditional rendering for loading, error, empty state, or the list of addresses
            if (controller.loading)
              const Center(child: CircularProgressIndicator())
            else if (controller.errorMessage != null)
              // Display an error message if fetching addresses failed
              Text(
                "Error: ${controller.errorMessage}",
                style: const TextStyle(color: Colors.red),
              )
            else if (controller.addresses.isEmpty)
              // Display a message if no addresses are found
              const Text("No addresses found. Please add a new one.")
            else
              // Expanded widget allows ListView.separated to take available vertical space and scroll
              Expanded(
                child: ListView.separated(
                  itemCount: controller.addresses.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final address = controller.addresses[index];
                    // Construct a clean, comma-separated address label
                    final label = [
                      if (address.houseNo != null &&
                          address.houseNo!.isNotEmpty)
                        address.houseNo,
                      if (address.area != null && address.area!.isNotEmpty)
                        address.area,
                      if (address.town != null && address.town!.isNotEmpty)
                        address.town,
                      if (address.state != null && address.state!.isNotEmpty)
                        address.state,
                      if (address.pincode != null &&
                          address.pincode!.isNotEmpty)
                        address.pincode,
                    ].whereType<String>().join(', ');

                    // Construct a subtitle that includes phone and landmark, if available
                    final subtitleParts = <String>[];
                    if (address.phoneNumber != null &&
                        address.phoneNumber!.isNotEmpty) {
                      subtitleParts.add(address.phoneNumber!);
                    }
                    if (address.landmark != null &&
                        address.landmark!.isNotEmpty) {
                      subtitleParts.add(address.landmark!);
                    }
                    final subtitle = subtitleParts.join(' • ');

                    return Card(
                      // Highlight the selected card with elevated shadow and border
                      elevation: selectedAddressId == address.id ? 4 : 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color:
                              selectedAddressId == address.id
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
                          width: selectedAddressId == address.id ? 2 : 1,
                        ),
                      ),
                      color:
                          selectedAddressId == address.id
                              ? Colors
                                  .deepPurple
                                  .shade50 // Light purple background for selected
                              : Theme.of(
                                context,
                              ).cardColor, // Default card color
                      child: RadioListTile<String>(
                        // RadioListTile is suitable for single selection from a list
                        title: Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            subtitle.isNotEmpty
                                ? Text(
                                  subtitle,
                                  style: TextStyle(color: Colors.grey.shade700),
                                )
                                : null, // Only show subtitle if it has content
                        value:
                            address.id!, // The unique value for this radio tile
                        groupValue:
                            selectedAddressId, // The currently selected ID in the group
                        onChanged: (String? value) {
                          setState(() {
                            selectedAddressId = value; // Update the selected ID
                            currentlySelectedAddress =
                                address; // Store the full address object
                          });
                        },
                        activeColor:
                            Colors
                                .deepPurple, // Color of the radio button when selected
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        secondary: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () async {
                                // Navigate to the AddressForm for editing
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => AddressForm(
                                          address: address,
                                        ), // Pass the existing address
                                    fullscreenDialog: true,
                                  ),
                                );
                                // After returning from AddressForm, refetch addresses to update the list
                                if (mounted) {
                                  Provider.of<DeliveryAddressController>(
                                    context,
                                    listen: false,
                                  ).fetchAddresses();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final bool confirmDelete =
                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Deletion"),
                                          content: const Text(
                                            "Are you sure you want to delete this address?",
                                          ),
                                          actions: <Widget>[
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
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ) ??
                                    false; // Default to false if dialog is dismissed

                                if (confirmDelete && address.id != null) {
                                  await controller.deleteAddress(address.id!);
                                  // After deletion, refetch addresses to update the list
                                  if (mounted) {
                                    Provider.of<DeliveryAddressController>(
                                      context,
                                      listen: false,
                                    ).fetchAddresses();
                                  }
                                  if (controller.errorMessage != null &&
                                      mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(controller.errorMessage!),
                                      ),
                                    );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Address deleted successfully",
                                        ),
                                      ),
                                    );
                                  }
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Navigate to the AddressForm for adding a new address
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  const AddressForm(), // No address passed for new
                          fullscreenDialog: true,
                        ),
                      );
                      // After returning from AddressForm, refetch addresses to update the list
                      // Check if the widget is still mounted to prevent errors after dispose
                      if (mounted) {
                        Provider.of<DeliveryAddressController>(
                          context,
                          listen: false,
                        ).fetchAddresses();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.deepPurple),
                    label: const Text(
                      "Add New Address",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Button to confirm the selected address
            ElevatedButton(
              onPressed:
                  selectedAddressId != null
                      ? () {
                        // Pop the bottom sheet and pass the ID of the selected address
                        Navigator.pop(context, currentlySelectedAddress?.id);
                      }
                      : null, // Button is disabled if no address is selected
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 7, 3, 201),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Confirm Selection",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            // Button to close the bottom sheet without selecting an address
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(
                  color: Colors.grey,
                ), // Differentiate from primary buttons
              ),
            ),
          ],
        ),
      ),
    );
  }
}
