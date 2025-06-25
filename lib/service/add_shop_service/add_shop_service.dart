import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';

class ShopService {
  final Dio _dio = Dio();
  final String baseUrl = "https://shop-app-backend-gsx6.onrender.com/api/shops";

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
        "locality": shop.locality,
        "email": shop.email,
        "mobileNumber": shop.mobileNumber,
        "landlineNumber ": shop.landlineNumber,
        "headerImage":
            imageFile != null
                ? await MultipartFile.fromFile(
                  imageFile.path,
                  filename: "shop_image.jpg",
                )
                : null,
        "userId": shop.userId,
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
    } finally {
      fetchShops();
    }
  }

  Future<void> updateShop(
    String id,
    ShopeDetailsModel shopDetails,
    String? token,
  ) async {
    final url = '$baseUrl/$id';

    try {
      FormData formData = FormData.fromMap({
        "shopName": shopDetails.shopName,
        "category":
            shopDetails.category!.isNotEmpty
                ? shopDetails.category!.first
                : null,
        "sellerType": shopDetails.sellerType,
        "state": shopDetails.state,
        "place": shopDetails.place,
        "pinCode": shopDetails.pinCode,
        // "locality": shopDetails.locality,
        // "userId": shopDetails.userId, // Include userId if your backend expects it for updates
        // if (shopDetails.active != null) "active": shopDetails.active,
        // if (shopDetails.pendingOrders != null) "pendingOrders": shopDetails.pendingOrders,
        // if (shopDetails.totalOrders != null) "totalOrders": shopDetails.totalOrders,
        // if (shopDetails.totalSales != null) "totalSales": shopDetails.totalSales,
        // Only include 'headerImage' if a new image file is provided.
        // if (newImageFile != null)
        //   "headerImage": await MultipartFile.fromFile(
        //     newImageFile.path,
        //     filename: "shop_image.jpg",
        //   ),
      });

      Map<String, dynamic> headers = {"Content-Type": "multipart/form-data"};
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await _dio.put(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        log("Shop updated successfully");
      } else {
        throw Exception(
          'Failed to update shop: ${response.statusMessage ?? response.data}',
        );
      }
    } on DioException catch (e) {
      log("Update error (DioException): ${e.response?.data ?? e.message}");
      throw Exception(
        "Error: ${e.response?.data['message'] ?? e.message ?? e.toString()}",
      );
    } catch (e) {
      log("Update error: $e");
      throw Exception("Error: $e");
    } finally {
      fetchShops();
    }
  }

  Future<void> deleteShop(String id) async {
    final url = '$baseUrl/$id';
    try {
      final response = await _dio.delete(url);
      if (response.statusCode == 200) {
        log("Shop deleted successfully: $id");
      } else {
        throw Exception(
          'Failed to delete shop: ${response.statusMessage ?? response.data}',
        );
      }
    } on DioException catch (e) {
      log("Delete error (DioException): ${e.response?.data ?? e.message}");
      throw Exception(
        "Error: ${e.response?.data['message'] ?? e.message ?? e.toString()}",
      );
    } catch (e) {
      log("Delete error: $e");
      throw Exception("Error: $e");
    } finally {
      fetchShops();
    }
  }
}
