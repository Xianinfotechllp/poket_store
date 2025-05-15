import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/service/address_service/address_service.dart';

class AddressController extends ChangeNotifier {
  final AddressService _service = AddressService();
  List<AddressModel> addresses = [];
  bool isLoading = false;

  Future<void> addAddress(AddressModel address) async {
    isLoading = true;
    notifyListeners();
    log('Attempting to add address...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      addresses = await _service.createAddress(userId, address);
      log('Address added successfully: ${address.toJson()}');
    } catch (e) {
      log('Error adding address: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAddresses() async {
    isLoading = true;
    notifyListeners();
    log('Fetching addresses...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      addresses = await _service.getAddresses(userId);
      log('Addresses fetched successfully. Count: ${addresses.length}');
    } catch (e) {
      log('Error fetching addresses: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<AddressModel> updateAddress(
      String addressId, AddressModel updatedAddress) async {
    log('Attempting to update address with ID: $addressId');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final updated =
          await _service.updateAddress(userId, addressId, updatedAddress);

      final index = addresses.indexWhere((element) => element.id == addressId);
      if (index != -1) {
        addresses[index] = updated;
        log('Address updated at index $index: ${updated.toJson()}');
      } else {
        log('Updated address not found in current list');
      }

      notifyListeners();
      return updated;
    } catch (e) {
      log('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    log('Attempting to delete address with ID: $addressId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      await _service.deleteAddress(userId, addressId);
      addresses.removeWhere((address) => address.id == addressId);
      log('Address deleted successfully: $addressId');

      notifyListeners();
    } catch (e) {
      log('Error deleting address: $e');
    }
  }
}
