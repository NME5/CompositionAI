import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _dataSyncEnabled = true;
  String _selectedUnit = 'Metric (kg, cm)';
  
  // Personal Information - now using UserProfile model
  UserProfile _userProfile;

  ProfileViewModel({UserProfile? userProfile}) 
    : _userProfile = userProfile ?? UserProfile(
        name: 'John Doe',
        age: 28,
        height: 175.0,
        gender: 'Male',
        activityLevel: 'Moderately Active',
        memberSince: DateTime.now(),
      );

  bool get notificationsEnabled => _notificationsEnabled;
  bool get dataSyncEnabled => _dataSyncEnabled;
  String get selectedUnit => _selectedUnit;
  
  // Personal Information getters
  UserProfile get userProfile => _userProfile;
  int get age => _userProfile.age;
  double get height => _userProfile.height;
  String get gender => _userProfile.gender;
  String get activityLevel => _userProfile.activityLevel;

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
    _userProfile.age = newAge;
    notifyListeners();
  }

  void updateHeight(double newHeight) {
    _userProfile.height = newHeight;
    notifyListeners();
  }

  void updateGender(String newGender) {
    _userProfile.gender = newGender;
    notifyListeners();
  }

  void updateActivityLevel(String newActivityLevel) {
    _userProfile.activityLevel = newActivityLevel;
    notifyListeners();
  }

  // Method to update the entire user profile at once if needed
  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners();
  }
}

