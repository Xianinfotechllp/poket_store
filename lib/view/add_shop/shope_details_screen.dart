import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:poketstore/view/add_shop/add_shop.dart'; // Import your AddShop screen
import 'package:provider/provider.dart';

class ShopeDetailsScreen extends StatelessWidget {
  final String shopId;

  const ShopeDetailsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopeDetailsProvider()..loadShopeDetails(shopId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Shop Details"),
          actions: [
            Consumer<ShopeDetailsProvider>(
              builder: (context, provider, child) {
                // Show edit button only if details are loaded
                if (provider.shopDetails != null) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final bool? didUpdate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddShop(
                              // shopToEdit: provider.shopDetails, // Pass the shop data
                              ),
                        ),
                      );
                      // If the AddShop screen returned true, it means an update occurred
                      if (didUpdate == true) {
                        provider.refreshDetails(shopId); // Refresh the details
                      }
                    },
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
                  // Text("Active: ${shop.active ? 'Yes' : 'No'}", style: const TextStyle(fontSize: 16)),
                  // Text("Pending Orders: ${shop.pendingOrders}", style: const TextStyle(fontSize: 16)),
                  // Text("Total Orders: ${shop.totalOrders}", style: const TextStyle(fontSize: 16)),
                  // Text("Total Sales: ${shop.totalSales}", style: const TextStyle(fontSize: 16)),
                  // Add more details as needed
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
