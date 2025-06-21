import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';

class ShopeDetailsScreen extends StatelessWidget {
  final String shopId;

  const ShopeDetailsScreen({super.key, required this.shopId});

  // Function to show the delete confirmation dialog
  Future<void> _confirmDelete(BuildContext context, String shopId) async {
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Delete Shop",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: const Text(
              "Are you sure you want to delete this shop? This action cannot be undone.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Color.fromARGB(255, 7, 3, 201)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx); // Close the dialog
                  final shopProvider = Provider.of<ShopProvider>(
                    context,
                    listen: false,
                  );
                  final shopOfUserProvider = Provider.of<ShopOfUserProvider>(
                    context,
                    listen: false,
                  );

                  await shopProvider.deleteShop(shopId, context, () {
                    shopOfUserProvider
                        .fetchUserShops(); // Refresh user's shop list
                    Navigator.of(context).pop(
                      true,
                    ); // Pop back to previous screen (ShopListScreen) with success
                  });

                  if (shopProvider.errorMessage.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(shopProvider.errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Shop deleted successfully!"),
                        backgroundColor: Color.fromARGB(255, 7, 3, 201),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 7, 3, 201),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Shop Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                Consumer<ShopeDetailsProvider>(
                  builder: (context, detailsProvider, child) {
                    if (detailsProvider.shopDetails != null) {
                      return PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final bool? didUpdate = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddShop(
                                      shopToEdit: detailsProvider.shopDetails,
                                    ),
                              ),
                            );
                            if (didUpdate == true) {
                              detailsProvider.refreshDetails(shopId);
                              Provider.of<ShopOfUserProvider>(
                                context,
                                listen: false,
                              ).fetchUserShops();
                            }
                          } else if (value == 'delete') {
                            _confirmDelete(context, shopId);
                          }
                        },
                        itemBuilder:
                            (BuildContext context) => [
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
          ),
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
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              );
            }

            final shop = provider.shopDetails!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        shop.headerImage.isNotEmpty
                            ? Image.network(
                              shop.headerImage,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width: double.infinity,
                                    height: 220,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                            : Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const Center(
                                child: Text(
                                  "No Image Available",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    shop.shopName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(height: 30, thickness: 1),
                  _buildDetailRow("Category", shop.category.join(', ')),
                  _buildDetailRow("Seller Type", shop.sellerType),
                  _buildDetailRow(
                    "Location",
                    "${shop.place ?? 'N/A'}, ${shop.locality ?? 'N/A'}, ${shop.state}",
                  ),
                  _buildDetailRow("Pincode", shop.pinCode),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
