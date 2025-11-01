import 'dart:async';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isConnected = false;
  bool _isScanning = false;
  int _currentStep = 0;
  double _progress = 0.0;

  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  int get currentStep => _currentStep;
  double get progress => _progress;

  void toggleConnection() {
    _isConnected = !_isConnected;
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

