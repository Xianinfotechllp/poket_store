import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/service/address_service/address_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing delivery addresses.
/// Extends [ChangeNotifier] to provide state management and notify listeners of changes.
class DeliveryAddressController extends ChangeNotifier {
  final DeliveryAddressService _service = DeliveryAddressService();

  List<Address> addresses = []; // List to hold fetched addresses
  bool loading = false; // Indicates if an operation is in progress
  String? errorMessage; // Stores any error messages

  /// Submits a new address to the backend.
  Future<void> submitAddress(Address address) async {
    loading = true;
    errorMessage = null; // Clear any previous errors
    notifyListeners(); // Notify UI that loading has started

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      errorMessage = "User ID not found in local storage. Please log in.";
      loading = false;
      notifyListeners(); // Notify UI about the error
      log(
        'DeliveryAddressController: User ID is null during address submission.',
      );
      return;
    }

    try {
      // Call the service to create the address, expecting AddressListResponse
      final AddressListResponse? result = await _service.createAddress(
        userId,
        address,
      );

      if (result != null) {
        addresses =
            result
                .addresses; // Update the list with addresses from the response
        log(
          'DeliveryAddressController: Address created successfully. Current addresses: ${addresses.length}',
        );
      } else {
        errorMessage =
            "Failed to create address: No data received or an error occurred on the server.";
        log(
          'DeliveryAddressController: Failed to create address, result was null.',
        );
      }
    } catch (e) {
      errorMessage = "Error creating address: $e";
      log('DeliveryAddressController: Error in submitAddress: $e');
    } finally {
      loading = false;
      notifyListeners(); // Notify UI that loading has ended (success or failure)
    }
  }

  /// Fetches existing delivery addresses for the current user.
  Future<void> fetchAddresses() async {
    loading = true;
    errorMessage = null; // Clear any previous errors
    notifyListeners(); // Notify UI that loading has started

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      errorMessage = "User ID not found in local storage. Please log in.";
      loading = false;
      notifyListeners(); // Notify UI about the error
      log('DeliveryAddressController: User ID is null during address fetch.');
      return;
    }

    try {
      // Call the service to get addresses, expecting AddressListResponse
      final AddressListResponse? result = await _service.getAddresses(userId);

      if (result != null) {
        addresses = result.addresses; // Update the list with fetched addresses
        log(
          'DeliveryAddressController: Addresses fetched successfully. Found ${addresses.length} addresses.',
        );
      } else {
        errorMessage =
            "Failed to fetch addresses: No data received or an error occurred on the server.";
        log(
          'DeliveryAddressController: Failed to fetch addresses, result was null.',
        );
      }
    } catch (e) {
      errorMessage = "Error fetching addresses: $e";
      log('DeliveryAddressController: Error in fetchAddresses: $e');
    } finally {
      loading = false;
      notifyListeners(); // Notify UI that loading has ended
    }
  }

  /// Updates an existing address.
  Future<void> updateAddress(String addressId, Address updatedAddress) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      errorMessage = "User ID not found in local storage. Please log in.";
      loading = false;
      notifyListeners();
      log('DeliveryAddressController: User ID is null during address update.');
      return;
    }

    try {
      final AddressListResponse? result = await _service.updateAddress(
        userId,
        addressId,
        updatedAddress,
      );

      if (result != null) {
        addresses = result.addresses; // Update the local list with the new data
        log(
          'DeliveryAddressController: Address updated successfully. Current addresses: ${addresses.length}',
        );
      } else {
        errorMessage =
            "Failed to update address: No data received or an error occurred on the server.";
        log(
          'DeliveryAddressController: Failed to update address, result was null.',
        );
      }
    } catch (e) {
      errorMessage = "Error updating address: $e";
      log('DeliveryAddressController: Error in updateAddress: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Deletes an existing address.
  Future<void> deleteAddress(String addressId) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      errorMessage = "User ID not found in local storage. Please log in.";
      loading = false;
      notifyListeners();
      log(
        'DeliveryAddressController: User ID is null during address deletion.',
      );
      return;
    }

    try {
      final AddressListResponse? result = await _service.deleteAddress(
        userId,
        addressId,
      );

      if (result != null) {
        addresses = result.addresses; // Update the local list after deletion
        log(
          'DeliveryAddressController: Address deleted successfully. Remaining addresses: ${addresses.length}',
        );
        // The UI (BottomSheet) will handle clearing its own selection based on the updated 'addresses' list.
      } else {
        errorMessage =
            "Failed to delete address: No data received or an error occurred on the server.";
        log(
          'DeliveryAddressController: Failed to delete address, result was null.',
        );
      }
    } catch (e) {
      errorMessage = "Error deleting address: $e";
      log('DeliveryAddressController: Error in deleteAddress: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
