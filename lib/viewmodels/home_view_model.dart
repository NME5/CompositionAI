import 'dart:async';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isConnected = false;
  bool _isScanning = false;
  int _currentStep = 0;
  double _progress = 0.0;
  String _deviceName = 'Bluetooth 1234';
  bool _showUnbindButton = true;

  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  int get currentStep => _currentStep;
  double get progress => _progress;
  String get deviceName => _deviceName;
  bool get showUnbindButton => _showUnbindButton;

  void toggleConnection() {
    _isConnected = !_isConnected;
    notifyListeners();
  }

  void bindScale({String? deviceName}) {
    _isConnected = true;
    if (deviceName != null) {
      _deviceName = deviceName;
    }
    _showUnbindButton = true;
    notifyListeners();
  }

  void unbindScale() {
    _isConnected = false;
    _showUnbindButton = false;
    _deviceName = 'No Scale Connected';
    notifyListeners();
  }

  void startScanning() {
    _isScanning = true;
    notifyListeners();
  }

  void stopScanning() {
    _isScanning = false;
    notifyListeners();
  }

  void startMeasurement() {
    _currentStep = 0;
    _progress = 0.0;
    notifyListeners();
    
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_currentStep < 2) {
        _currentStep++;
        _progress = (_currentStep + 1) / 3;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void resetMeasurement() {
    _currentStep = 0;
    _progress = 0.0;
    notifyListeners();
  }

  void updateProgress(double value) {
    _progress = value;
    notifyListeners();
  }
}

