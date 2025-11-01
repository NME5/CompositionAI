import 'package:flutter/material.dart';

class InsightsViewModel extends ChangeNotifier {
  String _selectedFilter = 'All';

  String get selectedFilter => _selectedFilter;

  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}

