import '../models/body_metrics.dart';
import '../models/user_profile.dart';
import '../models/insight.dart';
import '../models/device.dart';
import '../services/body_composition_calculator.dart';
import 'package:hive/hive.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _userProfileBoxName = 'userProfileBox';
  static const String _userProfileKey = 'profile';

  Box<UserProfile> get _userProfileBox => Hive.box<UserProfile>(_userProfileBoxName);

  // Lightweight app-wide settings (no adapter required)
  static const String _settingsBoxName = 'settingsBox';
  static const String _calcMethodKey = 'calculationMethod';
  Box get _settingsBox {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      throw Exception(
        'settingsBox must be opened in main.dart before use. '
        'Please restart the app (not just hot reload) if you see this error.'
      );
    }
    return Hive.box(_settingsBoxName);
  }

  static const String _boundDeviceBoxName = 'boundDeviceBox';
  static const String _boundDeviceKey = 'device';
  Box<Device> get _boundDeviceBox => Hive.box<Device>(_boundDeviceBoxName);

  static const String _metricsBoxName = 'metricsBox';
  Box<BodyMetrics> get _metricsBox => Hive.box<BodyMetrics>(_metricsBoxName);

  static const String _measurementsBoxName = 'measurementsBox';
  Box<MeasurementEntry> get _measurementsBox => Hive.box<MeasurementEntry>(_measurementsBoxName);

  // Mock data - replace with actual data fetching logic
  BodyMetrics getCurrentMetrics() {
    return BodyMetrics(
      weight: 72.5,
      muscleMass: 42.8,
      bodyFat: 18.2,
      water: 58.4,
      boneMass: 3.2,
      bmr: 1847,
    );
  }

  UserProfile getUserProfile() {
    final existing = _userProfileBox.get(_userProfileKey);
    if (existing != null) return existing;
    final defaultProfile = UserProfile(
      name: 'Timothy Juwono',
      age: 28,
      height: 175,
      gender: 'Male',
      activityLevel: 'Moderately Active',
      memberSince: DateTime(2023, 1, 1),
    );
    _userProfileBox.put(_userProfileKey, defaultProfile);
    return defaultProfile;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBox.put(_userProfileKey, profile);
  }

  // Calculation method (standard vs OKOK)
  CalculationMethod getCalculationMethod() {
    try {
      final stored = _settingsBox.get(_calcMethodKey);
      if (stored is int &&
          stored >= 0 &&
          stored < CalculationMethod.values.length) {
        return CalculationMethod.values[stored];
      }
    } catch (e) {
      print('[DataService] Error reading calculation method: $e');
    }
    return CalculationMethod.standard;
  }

  Future<void> setCalculationMethod(CalculationMethod method) async {
    await _settingsBox.put(_calcMethodKey, method.index);
  }

  // Update user profile name
  Future<void> updateUserName(String newName) async {
    final existing = _userProfileBox.get(_userProfileKey);
    if (existing != null) {
      final updatedProfile = existing.copyWith(name: newName);
      await _userProfileBox.put(_userProfileKey, updatedProfile);
    }
  }

  // Bound device persistence
  Device? getBoundDevice() {
    return _boundDeviceBox.get(_boundDeviceKey);
  }

  Future<void> setBoundDevice(Device? device) async {
    if (device == null) {
      await _boundDeviceBox.delete(_boundDeviceKey);
    } else {
      await _boundDeviceBox.put(_boundDeviceKey, device);
    }
  }

  bool isDeviceBound() {
    return _boundDeviceBox.containsKey(_boundDeviceKey);
  }

  // Body metrics history
  Future<void> addBodyMetrics(BodyMetrics metrics) async {
    await _metricsBox.add(metrics);
  }

  List<BodyMetrics> getAllBodyMetrics() {
    return _metricsBox.values.toList(growable: false);
  }

  Future<void> clearAllBodyMetrics() async {
    await _metricsBox.clear();
  }

  // Timestamped measurements (preferred)
  Future<void> addMeasurement(BodyMetrics metrics, {DateTime? timestamp}) async {
    final entry = MeasurementEntry(
      timestamp: timestamp ?? DateTime.now(),
      metrics: metrics,
    );
    await _measurementsBox.add(entry);
  }

  List<MeasurementEntry> getAllMeasurements() {
    return _measurementsBox.values.toList(growable: false);
  }

  Future<void> clearAllMeasurements() async {
    await _measurementsBox.clear();
  }

  HealthScore getHealthScore() {
    return HealthScore(
      overall: 85,
      bodyComp: 92,
      fitness: 78,
      wellness: 85,
    );
  }

  List<Recommendation> getRecommendations() {
    return [
      Recommendation(
        emoji: '🏃‍♂️',
        title: 'Cardio Optimization',
        description: 'Add 2 HIIT sessions per week to accelerate fat loss',
        priority: 'High Priority',
        priorityColor: 0xFF2196F3,
      ),
      Recommendation(
        emoji: '🥗',
        title: 'Protein Intake',
        description: 'Increase to 1.8g per kg body weight for muscle growth',
        priority: 'Medium Priority',
        priorityColor: 0xFF4CAF50,
      ),
      Recommendation(
        emoji: '😴',
        title: 'Recovery Time',
        description: 'Maintain 7-8 hours sleep for optimal recovery',
        priority: 'Maintain',
        priorityColor: 0xFF9C27B0,
      ),
    ];
  }

  List<Device> getAvailableDevices() {
    return [
      Device(
        id: '1',
        name: 'BodySync Pro X1',
      ),
      Device(
        id: '2',
        name: 'SmartScale Elite',
      ),
    ];
  }
}

