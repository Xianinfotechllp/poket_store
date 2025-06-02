import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/address_model/address_model.dart';

class AddressService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://shopappsabufree.work.gd:8000/api/delivery';

  Future<List<AddressModel>> createAddress(
      String userId, AddressModel address) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/create/$userId',
        data: {'address': address.toJson()},
      );

      if (response.statusCode == 200 && response.data['addresses'] != null) {
        List data = response.data['addresses'];
        return data.map((item) => AddressModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AddressModel>> getAddresses(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/get/$userId');
      if (response.statusCode == 200) {
        final data = response.data['addresses'] as List;
        return data.map((e) => AddressModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch addresses: ${response.statusCode}');
      }
    } catch (error) {
      if (error is DioException) {
        throw Exception('Dio error: ${error.message}');
      } else {
        throw Exception('Error fetching addresses: $error');
      }
    }
  }

  Future<AddressModel> updateAddress(
      String userId, String addressId, AddressModel updatedAddress) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/update/$userId/$addressId',
        data: updatedAddress.toJson(),
      );

      if (response.statusCode == 200) {
        return AddressModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update address: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('Dio Error: ${e.message}');
      log('Dio Error Type: ${e.type}');
      log('Dio Error Response: ${e.response?.data}');
      log('Dio Error Stacktrace: ${e.stackTrace}');
      throw Exception('Dio error during update: ${e.message}');
    } catch (e) {
      log('Error update: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/delete/$userId/$addressId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete address: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('Dio Error: ${e.message}');
      log('Dio Error Type: ${e.type}');
      log('Dio Error Response: ${e.response?.data}');
      log('Dio Error Stacktrace: ${e.stackTrace}');
      throw Exception('Dio error during deletion: ${e.message}');
    } catch (e) {
      log('Error delete: ${e.toString()}');
      rethrow;
    }
  }
}
