import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _dataSyncEnabled = true;
  String _selectedUnit = 'Metric (kg, cm)';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get dataSyncEnabled => _dataSyncEnabled;
  String get selectedUnit => _selectedUnit;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDataSync(bool value) {
    _dataSyncEnabled = value;
    notifyListeners();
  }

  void updateUnit(String unit) {
    _selectedUnit = unit;
    notifyListeners();
  }
}

