import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/cart_model/fetch_cart_model.dart';

class FetchCartService {
  final Dio dio = Dio();
  final String url = "https://shop-by-sabu-q.onrender.com/api/cart/user";

  Future<FetchCartModel?> fetchCart(String token) async {
    try {
      final response = await dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return FetchCartModel.fromJson(response.data);
      }
    } catch (e) {
      log("FetchCartService Error: $e");
    }
    return null;
  }
}
