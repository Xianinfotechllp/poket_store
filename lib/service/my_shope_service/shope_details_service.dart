import 'package:dio/dio.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';

class ShopeDetailsService {
  final Dio _dio = Dio();

  Future<ShopeDetailsModel> fetchShopeDetails(String id) async {
    final response = await _dio.get(
      'https://shop-by-sabu-q.onrender.com/api/shops/$id',
    );
    return ShopeDetailsModel.fromJson(response.data);
  }
}
