import 'package:flutter/material.dart';

class AnalyticsViewModel extends ChangeNotifier {
  String _selectedPeriod = '7D';

  String get selectedPeriod => _selectedPeriod;

  void selectPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  List<Map<String, dynamic>> get chartData => [
    {'x': 0, 'y': 0.8},
    {'x': 1, 'y': 0.7},
    {'x': 2, 'y': 0.65},
    {'x': 3, 'y': 0.55},
    {'x': 4, 'y': 0.5},
    {'x': 5, 'y': 0.45},
    {'x': 6, 'y': 0.35},
  ];
}

