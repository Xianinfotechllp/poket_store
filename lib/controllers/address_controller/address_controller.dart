// poketstore/controllers/address_controller/address_controller.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/service/address_service/address_service.dart';

class AddressController extends ChangeNotifier {
  final AddressService _service = AddressService();
  List<AddressModel> addresses = [];
  bool isLoading = false;
  String errorMessage = ''; // <--- Add this line to define errorMessage

  Future<void> addAddress(AddressModel address) async {
    isLoading = true;
    errorMessage = ''; // Clear any previous error message
    notifyListeners();
    log('Attempting to add address...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      // Assuming createAddress returns the updated list or the newly created address
      // If it returns the updated list, assign it directly.
      // If it returns just the new address, you might want to add it to the existing list.
      // For now, let's assume it returns the updated list of addresses.
      addresses = await _service.createAddress(userId, address);
      log('Address added successfully: ${address.toJson()}');
    } catch (e) {
      errorMessage = e.toString(); // Set the error message
      log('Error adding address: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAddresses() async {
    isLoading = true;
    errorMessage = ''; // Clear any previous error message
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
      errorMessage = e.toString(); // Set the error message
      log('Error fetching addresses: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress(
      String addressId, AddressModel updatedAddress) async {
    isLoading = true; // Set loading true at the start
    errorMessage = ''; // Clear any previous error message
    notifyListeners();
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
        log('Updated address not found in current list (might need to re-fetch all)');
        // Optionally, re-fetch all addresses if the updated one wasn't found
        // await getAddresses();
      }
      // No need to return updated here, as the UI will re-fetch or use the updated list
    } catch (e) {
      errorMessage = e.toString(); // Set the error message
      log('Error updating address: $e');
      // No rethrow here, as errorMessage is now handled by the controller
    } finally {
      isLoading = false; // Set loading false in finally block
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    isLoading = true;
    errorMessage = ''; // Clear any previous error message
    notifyListeners();
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
    } catch (e) {
      errorMessage = e.toString(); // Set the error message
      log('Error deleting address: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
