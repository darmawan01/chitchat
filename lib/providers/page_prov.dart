import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier {
  int _pageInit = 2;
  int get pageinit => _pageInit;

  void setPage(int val) {
    _pageInit = val;
    notifyListeners();
  }
}
