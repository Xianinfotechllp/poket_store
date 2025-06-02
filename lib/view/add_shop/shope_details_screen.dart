import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart'; // Assuming ShopProvider is here
import 'package:provider/provider.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';

class ShopeDetailsScreen extends StatelessWidget {
  final String shopId;

  const ShopeDetailsScreen({super.key, required this.shopId});

  // Function to show the delete confirmation dialog
  void _confirmDelete(BuildContext context, String shopId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Shop"),
        content: const Text(
          "Are you sure you want to delete this shop? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog first
              final shopProvider =
                  Provider.of<ShopProvider>(context, listen: false);
              await shopProvider.deleteShop(shopId);

              if (shopProvider.errorMessage.isEmpty) {
                // If deletion was successful, pop this screen and send a 'true' result
                // to indicate that the previous screen should refresh.
                Navigator.of(context).pop(true);
              } else {
                // Show an error message if deletion failed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Error deleting shop: ${shopProvider.errorMessage}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Red color for delete button
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopeDetailsProvider()..loadShopeDetails(shopId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Shop Details"),
          actions: [
            Consumer<ShopeDetailsProvider>(
              builder: (context, detailsProvider, child) {
                if (detailsProvider.shopDetails != null) {
                  return PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final bool? didUpdate = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddShop(
                              shopToEdit: detailsProvider.shopDetails,
                            ),
                          ),
                        );
                        if (didUpdate == true) {
                          // Refresh details if AddShop indicates an update
                          detailsProvider.refreshDetails(shopId);
                        }
                      } else if (value == 'delete') {
                        _confirmDelete(context, shopId);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
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
                return const SizedBox.shrink();
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
                child: Text(
                  provider.errorMessage.isEmpty
                      ? "Shop details not found."
                      : provider.errorMessage,
                ),
              );
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
                  Text(
                      "Location: ${shop.place ?? 'N/A'}, ${shop.locality ?? 'N/A'}, ${shop.state}",
                      style: const TextStyle(fontSize: 16)),
                  Text("Pincode: ${shop.pinCode}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
