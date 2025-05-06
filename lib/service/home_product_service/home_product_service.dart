import 'package:dio/dio.dart';
import 'package:poketstore/model/home_product_model/home_product_model.dart';

class HomeProductService {
  final Dio _dio = Dio();

  Future<List<HomeProduct>> fetchHomeProducts(String shopId) async {
    try {
      final response = await _dio.get(
        'https://shop-app-backend-gsx6.onrender.com/api/products/nearbyshop/$shopId',
      );

      if (response.statusCode == 200 && response.data['products'] != null) {
        List data = response.data['products'];
        return data.map((item) => HomeProduct.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}
