import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/my_shop_list_user_model.dart';
import 'package:poketstore/service/my_shope_service/my_shop_list_user_service.dart';

class MyShopListUserProvider extends ChangeNotifier {
  final MyShopListUserService _service = MyShopListUserService();

  List<ShopData> shopList = [];
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> allProductsWithShopName = [];

  Future<void> fetchUserShopList(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchUserShopList(userId);
      shopList = response.data;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      shopList = [];
      notifyListeners();
    }
  }
}
