import 'package:flutter/material.dart';
import 'package:poketstore/model/shop_of_user_model/shop_of_user_model.dart';
import 'package:poketstore/service/shop_of_user_service/shop_of_user_service.dart';

class ShopOfUserProvider extends ChangeNotifier {
  List<ShopOfUser> shopList = [];
  String errorMessage = "";
  bool isLoading = false;

  Future<void> fetchUserShops() async {
    try {
      isLoading = true;
      notifyListeners();
      final shops = await ShopOfUserService().getShopsByUser();
      shopList = shops;
      errorMessage = "";
    } catch (e) {
      errorMessage = "Failed to load shops.";
    }
    isLoading = false;
    notifyListeners();
  }
}
