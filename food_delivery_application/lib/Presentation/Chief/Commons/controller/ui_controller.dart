import 'package:flutter/material.dart';

class UIcontroller extends ChangeNotifier {
  late int currentIndex = 0;
  late PageController pageController;

  late PageStorageBucket pageStorageBucket;
  UIcontroller() {
    // Initialize the PageController in the constructor
    pageController = PageController(initialPage: 0);
    pageStorageBucket = PageStorageBucket();
  }

  void changeindex(int index) {
    currentIndex = index;

    notifyListeners();
  }
}
