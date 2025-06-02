import 'package:dio/dio.dart';
import 'package:poketstore/model/groceries_list_model/groceries_list_model.dart';

class GroceriesListService {
  final Dio _dio = Dio();
  final String _url =
      'http://shopappsabufree.work.gd:8000/api/category/Key/WithFixedCategory';

  Future<GroceriesListModel?> fetchGroceriesList() async {
    try {
      final response = await _dio.get(_url);
      if (response.statusCode == 200) {
        return GroceriesListModel.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching groceries list: $e');
    }
    return null;
  }
}
