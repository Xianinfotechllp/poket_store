import 'package:dio/dio.dart';
import 'package:poketstore/model/category_model/category_model.dart';

class CategoryService {
  final Dio _dio = Dio();
  final String _endpoint =
      'http://shopappsabufree.work.gd:8000/api/category/FixedCategory';

  Future<CategoryModel> fetchCategories() async {
    try {
      final response = await _dio.get(_endpoint);
      return CategoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
