import 'dart:developer';
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

  Future<void> updateShopDetails(ShopModel shopModel) async {
    isLoading = true;
    notifyListeners();

    try {
      // Send 'category' as a String if the API requires a single category
      final data = {
        "shopName": shopModel.shopName,
        "category":
            shopModel.category.isNotEmpty ? shopModel.category.first : "",
        "sellerType": shopModel.sellerType,
        "state": shopModel.state,
        "pinCode": shopModel.pinCode,
      };

      await _shopService.updateShop(shopModel.id!, data);
      log("Update complete.");
    } catch (e) {
      log("Provider error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
