import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _dataSyncEnabled = true;
  String _selectedUnit = 'Metric (kg, cm)';
  
  // Personal Information
  int _age = 28;
  double _height = 175.0;
  double _weight = 72.5;
  String _activityLevel = 'Moderately Active';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get dataSyncEnabled => _dataSyncEnabled;
  String get selectedUnit => _selectedUnit;
  int get age => _age;
  double get height => _height;
  double get weight => _weight;
  String get activityLevel => _activityLevel;

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

  void updateAge(int newAge) {
    _age = newAge;
    notifyListeners();
  }

  void updateHeight(double newHeight) {
    _height = newHeight;
    notifyListeners();
  }

  void updateWeight(double newWeight) {
    _weight = newWeight;
    notifyListeners();
  }

  void updateActivityLevel(String newActivityLevel) {
    _activityLevel = newActivityLevel;
    notifyListeners();
  }
}

