import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/service/add_shop_service/add_shop_service.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService();
  List<ShopModel> shops = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchShops() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      shops = await _shopService.fetchShops();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addShop(ShopModel shop, File? imageFile) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _shopService.addShop(shop, imageFile);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
