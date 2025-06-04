import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/shop_of_user_model/shop_of_user_model.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/add_shop/shope_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';

class ShopListScreen extends StatefulWidget {
  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shops")),
      body: Consumer<ShopOfUserProvider>(
        builder: (context, shopProvider, child) {
          return RefreshIndicator(
            onRefresh: () => shopProvider.fetchUserShops(),
            child: shopProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : shopProvider.shopList.isEmpty
                    ? const Center(child: Text("No shops available."))
                    : ListView.builder(
                        itemCount: shopProvider.shopList.length,
                        itemBuilder: (context, index) {
                          final shop = shopProvider.shopList[index];
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: Image.network(
                                shop.headerImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                        Icons.broken_image), // Fallback image
                              ),
                              title: Text(shop.shopName),
                              subtitle: Text("${shop.place}, ${shop.state}"),
                              trailing: Text(shop.sellerType),
                              onTap: () async {
                                // Made onTap async
                                final bool? result = await Navigator.push(
                                  // Await the navigation
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ShopeDetailsScreen(shopId: shop.id),
                                  ),
                                );
                                // Check if the result is true, indicating a successful update/deletion
                                if (result == true) {
                                  shopProvider
                                      .fetchUserShops(); // Refresh the list
                                }
                              },
                            ),
                          );
                        },
                      ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_shop",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddShop()),
          ).then((_) {
            Provider.of<ShopOfUserProvider>(context, listen: false)
                .fetchUserShops();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
