import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poketstore/model/my_shope_model/my_shop_list_user_model.dart';

class MyShopListUserService {
  final String baseUrl = 'https://shop-app-backend-gsx6.onrender.com/api';

  Future<MyShopListUserResponse> fetchUserShopList(String userId) async {
    final Uri uri = Uri.parse('$baseUrl/products/user/$userId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MyShopListUserResponse.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch user shop list: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server: $error');
    }
  }
}
