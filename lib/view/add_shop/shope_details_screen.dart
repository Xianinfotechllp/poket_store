// poketstore/view/my_shope/shope_details_screen.dart
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart'; // Import ShopProvider
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:provider/provider.dart';

class ShopeDetailsScreen extends StatelessWidget {
  final String shopId;

  const ShopeDetailsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Use MultiProvider if you need both details and the general ShopProvider
      providers: [
        ChangeNotifierProvider(
          create: (_) => ShopeDetailsProvider()..loadShopeDetails(shopId),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(), // Provide the general ShopProvider
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Shop Details"),
          actions: [
            Consumer<ShopeDetailsProvider>(
              builder: (context, detailsProvider, child) {
                // Show edit button only if details are loaded
                if (detailsProvider.shopDetails != null) {
                  return PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final bool? didUpdate = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddShop(
                              shopToEdit: detailsProvider
                                  .shopDetails, // Pass ShopeDetailsModel
                            ),
                          ),
                        );
                        if (didUpdate == true) {
                          detailsProvider
                              .refreshDetails(shopId); // Refresh the details
                        }
                      } else if (value == 'delete') {
                        // Show confirmation dialog before deleting
                        final bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: Text(
                                  "Are you sure you want to delete ${detailsProvider.shopDetails!.shopName}?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text("Delete"),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          final shopProvider =
                              Provider.of<ShopProvider>(context, listen: false);
                          await shopProvider.deleteShop(shopId);

                          if (shopProvider.errorMessage.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Shop deleted successfully!")),
                            );
                            // Navigate back after successful deletion, potentially to the list of shops
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Failed to delete shop: ${shopProvider.errorMessage}")),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Shop'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Shop'),
                      ),
                    ],
                  );
                }
                return const SizedBox
                    .shrink(); // Hide button if no shop details
              },
            ),
          ],
        ),
        body: Consumer<ShopeDetailsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.shopDetails == null) {
              return Center(
                  child: Text(provider.errorMessage.isEmpty
                      ? "Shop details not found."
                      : provider.errorMessage));
            }

            final shop = provider.shopDetails!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: shop.headerImage.isNotEmpty
                        ? Image.network(
                            shop.headerImage,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child:
                                const Center(child: Text("No Image Available")),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    shop.shopName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Category: ${shop.category.join(', ')}",
                      style: const TextStyle(fontSize: 16)),
                  Text("Seller Type: ${shop.sellerType}",
                      style: const TextStyle(fontSize: 16)),
                  // Text("Location: ${shop.place ?? 'N/A'}, ${shop.locality ?? 'N/A'}, ${shop.state}", style: const TextStyle(fontSize: 16)),
                  Text("Pincode: ${shop.pinCode}",
                      style: const TextStyle(fontSize: 16)),
                  // Text("Active: ${shop.active == true ? 'Yes' : 'No'}", style: const TextStyle(fontSize: 16)),
                  // Text("Pending Orders: ${shop.pendingOrders ?? 0}", style: const TextStyle(fontSize: 16)),
                  // Text("Total Orders: ${shop.totalOrders ?? 0}", style: const TextStyle(fontSize: 16)),
                  // Text("Total Sales: ${shop.totalSales ?? 0}", style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
