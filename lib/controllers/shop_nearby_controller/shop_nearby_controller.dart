import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';
import 'package:poketstore/service/shop_nearby_service/shop_nearby_service.dart';

class ShopNearbyController extends ChangeNotifier {
  final ShopNearbyService _service = ShopNearbyService();

  List<ShopNearbyModel> _shops = [];
  bool _isLoading = false;
  String? _error;

  List<ShopNearbyModel> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches nearby shops using the userId from SharedPreferences
  Future<void> loadNearbyShops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = 'User ID not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _shops = await _service.fetchNearbyShops(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
