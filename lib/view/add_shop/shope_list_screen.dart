import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart'; // Import ShopeDetailsModel
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/add_shop/shope_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch shops when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true, title: "My Shops"),
      // PreferredSize(
      //   preferredSize: const Size.fromHeight(60),
      //   child: Container(
      //     decoration: const BoxDecoration(
      //       color: Color.fromARGB(255, 7, 3, 201),
      //       borderRadius: BorderRadius.only(
      //         bottomLeft: Radius.circular(25),
      //         bottomRight: Radius.circular(25),
      //       ),
      //     ),
      //     child: AppBar(
      //       backgroundColor: Colors.transparent,
      //       elevation: 0,
      //       centerTitle: true,
      //       title: const Text(
      //         "My Shops",
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontSize: 20,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       iconTheme: const IconThemeData(color: Colors.white),
      //     ),
      //   ),
      // ),
      body: Consumer<ShopOfUserProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shopProvider.shopList.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => shopProvider.fetchUserShops(),
              child: const Center(
                child: SingleChildScrollView(
                  physics:
                      AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh even with no content
                  child: Text(
                    "No shops available. Tap '+' to add your first shop!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => shopProvider.fetchUserShops(),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: shopProvider.shopList.length,
              itemBuilder: (context, index) {
                final shop = shopProvider.shopList[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () async {
                      // Navigate to ShopeDetailsScreen and await result
                      final bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopeDetailsScreen(shopId: shop.id),
                        ),
                      );
                      // If result is true, it means an update or delete occurred, so refresh the list
                      if (result == true) {
                        shopProvider.fetchUserShops();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                shop.headerImage.isNotEmpty
                                    ? Image.network(
                                      shop.headerImage,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 30,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    )
                                    : Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.store,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop.shopName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 7, 3, 201),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${shop.place ?? 'N/A'}, ${shop.state}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 8,
                                //     vertical: 4,
                                //   ),
                                //   decoration: BoxDecoration(
                                //     color: Colors.blue.withOpacity(0.1),
                                //     borderRadius: BorderRadius.circular(5),
                                //   ),
                                //   child: const Text(
                                //     "Seller", // Assuming seller type from your original code, this can be shop.sellerType
                                //     style: TextStyle(
                                //       fontSize: 12,
                                //       fontWeight: FontWeight.bold,
                                //       color: Colors.blue,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_shop",
        onPressed: () async {
          // Await the result from AddShop screen
          final bool? didAddShop = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddShop()),
          );
          // If a shop was successfully added, refresh the list
          if (didAddShop == true) {
            Provider.of<ShopOfUserProvider>(
              context,
              listen: false,
            ).fetchUserShops();
          }
        },
        label: const Text(
          "Add New Shop",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
