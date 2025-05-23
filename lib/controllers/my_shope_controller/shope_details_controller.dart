import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
import 'package:poketstore/service/my_shope_service/shope_details_service.dart';

class ShopeDetailsProvider extends ChangeNotifier {
  final ShopeDetailsService _service = ShopeDetailsService();
  ShopeDetailsModel? shopDetails;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadShopeDetails(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      shopDetails = await _service.fetchShopeDetails(id);
    } catch (e) {
      errorMessage = "Failed to load shop details";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDetails(String shopId) async {
    await loadShopeDetails(shopId);
  }
}
