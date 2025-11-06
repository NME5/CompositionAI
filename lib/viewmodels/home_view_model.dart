import 'dart:async';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/device.dart';

class HomeViewModel extends ChangeNotifier {
  final DataService _dataService = DataService();
  bool _isConnected = false;
  bool _isScanning = false;
  int _currentStep = 0;
  double _progress = 0.0;
  String _deviceName = 'No Scale Connected';
  bool _showUnbindButton = true;

  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  int get currentStep => _currentStep;
  double get progress => _progress;
  String get deviceName => _deviceName;
  bool get showUnbindButton => _showUnbindButton;

  Future<void> initializeBinding() async {
    final device = _dataService.getBoundDevice();
    if (device != null) {
      _isConnected = true;
      _deviceName = device.name;
      _showUnbindButton = true;
    } else {
      _isConnected = false;
      _deviceName = 'No Scale Connected';
      _showUnbindButton = false;
    }
    notifyListeners();
  }

  void toggleConnection() {
    _isConnected = !_isConnected;
    notifyListeners();
  }

  void bindScale({String? deviceName, String? deviceId}) {
    _isConnected = true;
    if (deviceName != null) {
      _deviceName = deviceName;
    }
    _showUnbindButton = true;
    _dataService.setBoundDevice(Device(
      id: deviceId ?? _deviceName,
      name: _deviceName,
    ));
    notifyListeners();
  }

  void unbindScale() {
    _isConnected = false;
    _showUnbindButton = false;
    _deviceName = 'No Scale Connected';
    _dataService.setBoundDevice(null);
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

