import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';

class ShopService {
  final Dio _dio = Dio();
  final String baseUrl = "https://shop-app-backend-main.onrender.com/api/shops";

  Future<List<ShopModel>> fetchShops() async {
    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ShopModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load shops");
      }
    } catch (e) {
      throw Exception("Error fetching shops: $e");
    }
  }

  Future<void> addShop(ShopModel shop, File? imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        "shopName": shop.shopName,
        "category": shop.category,
        "sellerType": shop.sellerType,
        "state": shop.state,
        "place": shop.place,
        "pinCode": shop.pinCode,
        "headerImage":
            imageFile != null
                ? await MultipartFile.fromFile(
                  imageFile.path,
                  filename: "shop_image.jpg",
                )
                : null,
      });

      Response response = await _dio.post(
        baseUrl,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log("Shop added successfully");
      } else {
        throw Exception("Failed to add shop");
      }
    } catch (e) {
      log("Error adding shop: $e");
      throw Exception("Error: $e");
    }
  }
}
