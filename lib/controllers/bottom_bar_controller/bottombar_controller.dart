import 'package:flutter/material.dart';
import 'package:poketstore/view/home/view/home_screen/home_screen.dart';

class BottomBarProvider extends ChangeNotifier {
  int selectedIndex = 0; // Track selected index

  void changeTab(int index) {
    selectedIndex = index;

    notifyListeners();
  }
}
