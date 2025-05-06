import 'package:flutter/material.dart';
import 'package:poketstore/model/groceries_list_model/groceries_list_model.dart';
import 'package:poketstore/service/groceries_list_service/groceries_list_service.dart';

class GroceriesListProvider extends ChangeNotifier {
  final GroceriesListService _service = GroceriesListService();

  GroceriesListModel? groceriesList;
  bool isLoading = false;

  Future<void> loadGroceriesList() async {
    isLoading = true;
    notifyListeners();

    groceriesList = await _service.fetchGroceriesList();

    isLoading = false;
    notifyListeners();
  }
}
