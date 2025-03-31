import 'package:flutter/material.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:provider/provider.dart';

class ShopListScreen extends StatefulWidget {
  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shops")),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (shopProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(shopProvider.errorMessage));
          }

          if (shopProvider.shops.isEmpty) {
            return Center(child: Text("No shops available"));
          }

          return ListView.builder(
            itemCount: shopProvider.shops.length,
            itemBuilder: (context, index) {
              ShopModel shop = shopProvider.shops[index];
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "add_shop",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddShop()),
              );
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
