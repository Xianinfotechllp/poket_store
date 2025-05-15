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
      appBar: AppBar(title: Text("Shops")),
      body: Consumer<ShopOfUserProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (shopProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(shopProvider.errorMessage));
          }

          if (shopProvider.shopList.isEmpty) {
            return Center(child: Text("No shops available."));
          }

          return ListView.builder(
            itemCount: shopProvider.shopList.length,
            itemBuilder: (context, index) {
              ShopOfUser shop = shopProvider.shopList[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    shop.headerImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(shop.shopName),
                  subtitle: Text("${shop.place}, ${shop.state}"),
                  trailing: Text(shop.sellerType),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ShopeDetailsScreen(shopId: shop.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_shop",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddShop()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
