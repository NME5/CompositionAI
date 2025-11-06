import '../models/body_metrics.dart';
import '../models/user_profile.dart';
import '../models/insight.dart';
import '../models/device.dart';
import 'package:hive/hive.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _userProfileBoxName = 'userProfileBox';
  static const String _userProfileKey = 'profile';

  Box<UserProfile> get _userProfileBox => Hive.box<UserProfile>(_userProfileBoxName);

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
      name: 'Alex Johnson',
      age: 28,
      height: 175,
      gender: 'Male',
      activityLevel: 'Moderately Active',
      membershipType: 'Premium Member',
      memberSince: DateTime(2023, 1, 1),
    );
    _userProfileBox.put(_userProfileKey, defaultProfile);
    return defaultProfile;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBox.put(_userProfileKey, profile);
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
        details: 'Signal: Strong • 2.4m away',
        isStrong: true,
      ),
      Device(
        id: '2',
        name: 'SmartScale Elite',
        details: 'Signal: Medium • 5.1m away',
        isStrong: false,
      ),
    ];
  }
}

