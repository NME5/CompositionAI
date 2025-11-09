import 'dart:async';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/device.dart';
import '../models/body_metrics.dart';

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

  /// Formats a body measurement date ke last measurement, dan format ke x days ago, x weeks ago, x months ago, x years ago, atau date
  /// [entry] - The measurement entry to format
  /// [isFirst] - Whether this is the first/most recent item (for "Last measurement" label)
  String formatRelativeDate(MeasurementEntry entry, {bool isFirst = false}) {
    final dt = entry.timestamp;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final measurementDate = DateTime(dt.year, dt.month, dt.day);
    final difference = today.difference(measurementDate).inDays;

    // Format time
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hh:$mm';

    if (difference == 0) {
      // Today
      return isFirst ? 'Today at $timeStr' : 'Today, $timeStr';
    } else if (difference == 1) {
      // Yesterday
      return 'Yesterday at $timeStr';
    } else if (difference < 7) {
      // 2-6 days ago
      return '$difference days ago';
    } else if (difference < 14) {
      // 1 week ago
      return '1 week ago';
    } else if (difference < 30) {
      // Weeks ago
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference < 365) {
      // Months ago
      final months = (difference / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      // Years ago or fallback to date
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}

