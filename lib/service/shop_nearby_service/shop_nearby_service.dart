import 'package:dio/dio.dart';
import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';

class ShopNearbyService {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://shop-app-backend-gsx6.onrender.com/api/shops/nearby';

  Future<List<ShopNearbyModel>> fetchNearbyShops(String userId) async {
    try {
      final response = await _dio.get('$baseUrl/$userId');
      if (response.statusCode == 200) {
        final data = response.data['shops'] as List;
        return data.map((json) => ShopNearbyModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch shops');
      }
    } catch (e) {
      rethrow;
    }
  }
}
