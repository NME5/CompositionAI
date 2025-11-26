import 'package:flutter/material.dart';

/// Health Threshold Service
/// Implements health level calculations based on standard thresholds
/// Reference: HEALTH_MEASUREMENT_THRESHOLDS.md
class HealthThresholdService {
  /// Calculate BMI health level
  /// Returns: 1 = Underweight, 2 = Normal, 3 = Overweight, 4 = Obese
  static int getBmiLevel(double bmi) {
    if (bmi < 18.5) return 1; // Underweight
    if (bmi < 23.9) return 2; // Normal/Healthy
    if (bmi < 28.0) return 3; // Overweight
    return 4; // Obese
  }

  /// Get BMI health status text
  static String getBmiStatusText(double bmi) {
    final level = getBmiLevel(bmi);
    switch (level) {
      case 1:
        return 'Underweight';
      case 2:
        return 'Normal';
      case 3:
        return 'Overweight';
      case 4:
        return 'Obese';
      default:
        return 'Unknown';
    }
  }

  /// Calculate Body Fat Percentage health level
  /// Returns: 1 = Low, 2 = Standard, 3 = High, 4 = Very High
  static int getBodyFatLevel({
    required double bodyFatPercent,
    required bool isMale,
    required int age,
  }) {
    // Male thresholds
    if (isMale) {
      if (age <= 39) {
        if (bodyFatPercent < 11.0) return 1;
        if (bodyFatPercent < 17.0) return 2;
        if (bodyFatPercent < 27.0) return 3;
        return 4;
      } else if (age <= 59) {
        if (bodyFatPercent < 12.0) return 1;
        if (bodyFatPercent < 18.0) return 2;
        if (bodyFatPercent < 28.0) return 3;
        return 4;
      } else {
        // age >= 60
        if (bodyFatPercent < 14.0) return 1;
        if (bodyFatPercent < 20.0) return 2;
        if (bodyFatPercent < 30.0) return 3;
        return 4;
      }
    } else {
      // Female thresholds
      if (age <= 39) {
        if (bodyFatPercent < 21.0) return 1;
        if (bodyFatPercent < 28.0) return 2;
        if (bodyFatPercent < 40.0) return 3;
        return 4;
      } else if (age <= 59) {
        if (bodyFatPercent < 22.0) return 1;
        if (bodyFatPercent < 29.0) return 2;
        if (bodyFatPercent < 41.0) return 3;
        return 4;
      } else {
        // age >= 60
        if (bodyFatPercent < 23.0) return 1;
        if (bodyFatPercent < 30.0) return 2;
        if (bodyFatPercent < 42.0) return 3;
        return 4;
      }
    }
  }

  /// Get Body Fat health status text
  static String getBodyFatStatusText({
    required double bodyFatPercent,
    required bool isMale,
    required int age,
  }) {
    final level = getBodyFatLevel(
      bodyFatPercent: bodyFatPercent,
      isMale: isMale,
      age: age,
    );
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Healthy';
      case 3:
        return 'High';
      case 4:
        return 'Very High';
      default:
        return 'Unknown';
    }
  }

  /// Calculate Body Water Percentage health level
  /// Returns: 1 = Low, 2 = Standard, 3 = High
  static int getWaterLevel({
    required double waterPercent,
    required bool isMale,
    required int age,
  }) {
    if (isMale) {
      if (age <= 30) {
        if (waterPercent < 53.6) return 1;
        if (waterPercent <= 57.0) return 2;
        return 3;
      } else {
        if (waterPercent <= 52.3) return 1;
        if (waterPercent <= 55.6) return 2;
        return 3;
      }
    } else {
      if (age <= 30) {
        if (waterPercent < 49.5) return 1;
        if (waterPercent <= 52.9) return 2;
        return 3;
      } else {
        if (waterPercent < 48.1) return 1;
        if (waterPercent <= 51.5) return 2;
        return 3;
      }
    }
  }

  /// Get Water health status text
  static String getWaterStatusText({
    required double waterPercent,
    required bool isMale,
    required int age,
  }) {
    final level = getWaterLevel(
      waterPercent: waterPercent,
      isMale: isMale,
      age: age,
    );
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Healthy';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  /// Calculate Visceral Fat health level
  /// Returns: 1 = Very Low, 2 = Healthy, 3 = High, 4 = Dangerous
  static int getVisceralFatLevel(double vfr) {
    if (vfr < 1.0) return 1;
    if (vfr < 10.0) return 2;
    if (vfr <= 14.0) return 3;
    return 4;
  }

  /// Get Visceral Fat health status text
  static String getVisceralFatStatusText(double vfr) {
    final level = getVisceralFatLevel(vfr);
    switch (level) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Healthy';
      case 3:
        return 'High';
      case 4:
        return 'Dangerous';
      default:
        return 'Unknown';
    }
  }

  /// Calculate Muscle Mass health level based on skeletal muscle percentage
  /// Returns: 1 = Low, 2 = Standard, 3 = High
  static int getMuscleLevel({
    required double musclePercent, // Skeletal muscle percentage
    required bool isMale,
    required double heightCm,
  }) {
    double minStandard, maxStandard;
    
    if (isMale) {
      if (heightCm < 160) {
        minStandard = 21.2;
        maxStandard = 26.6;
      } else if (heightCm <= 170) {
        minStandard = 24.8;
        maxStandard = 34.6;
      } else {
        minStandard = 29.6;
        maxStandard = 43.2;
      }
    } else {
      if (heightCm < 150) {
        minStandard = 16.0;
        maxStandard = 20.6;
      } else if (heightCm <= 160) {
        minStandard = 18.9;
        maxStandard = 23.7;
      } else {
        minStandard = 22.1;
        maxStandard = 30.3;
      }
    }
    
    if (musclePercent < minStandard) return 1;
    if (musclePercent <= maxStandard) return 2;
    return 3;
  }

  /// Get Muscle health status text
  static String getMuscleStatusText({
    required double musclePercent,
    required bool isMale,
    required double heightCm,
  }) {
    final level = getMuscleLevel(
      musclePercent: musclePercent,
      isMale: isMale,
      heightCm: heightCm,
    );
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Healthy';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  /// Calculate Bone Mass health level
  /// Returns: 1 = Low, 2 = Standard, 3 = High
  static int getBoneMassLevel({
    required double boneMassKg,
    required bool isMale,
    required int age,
  }) {
    double minStandard, maxStandard;
    
    if (isMale) {
      if (age <= 54) {
        minStandard = 1.68;
        maxStandard = 3.12;
      } else if (age <= 75) {
        minStandard = 1.96;
        maxStandard = 3.64;
      } else {
        minStandard = 2.17;
        maxStandard = 4.03;
      }
    } else {
      if (age <= 39) {
        minStandard = 1.19;
        maxStandard = 2.21;
      } else if (age <= 60) {
        minStandard = 1.47;
        maxStandard = 2.73;
      } else {
        minStandard = 1.68;
        maxStandard = 3.12;
      }
    }
    
    if (boneMassKg < minStandard) return 1;
    if (boneMassKg <= maxStandard) return 2;
    return 3;
  }

  /// Get Bone Mass health status text
  static String getBoneMassStatusText({
    required double boneMassKg,
    required bool isMale,
    required int age,
  }) {
    final level = getBoneMassLevel(
      boneMassKg: boneMassKg,
      isMale: isMale,
      age: age,
    );
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Healthy';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  /// Calculate BMR health level
  /// Returns: 1 = Low, 2 = Standard, 3 = High
  static int getBMRLevel({
    required double bmr,
    required bool isMale,
    required int age,
  }) {
    double standard;
    
    if (isMale) {
      if (age <= 2) {
        standard = 700;
      } else if (age <= 5) {
        standard = 900;
      } else if (age <= 8) {
        standard = 1090;
      } else if (age <= 11) {
        standard = 1290;
      } else if (age <= 14) {
        standard = 1480;
      } else if (age <= 17) {
        standard = 1610;
      } else if (age <= 29) {
        standard = 1550;
      } else if (age <= 49) {
        standard = 1500;
      } else if (age <= 69) {
        standard = 1350;
      } else {
        standard = 1220;
      }
    } else {
      if (age <= 2) {
        standard = 700;
      } else if (age <= 5) {
        standard = 860;
      } else if (age <= 8) {
        standard = 1000;
      } else if (age <= 11) {
        standard = 1180;
      } else if (age <= 14) {
        standard = 1340;
      } else if (age <= 17) {
        standard = 1300;
      } else if (age <= 29) {
        standard = 1210;
      } else if (age <= 49) {
        standard = 1170;
      } else if (age <= 69) {
        standard = 1110;
      } else {
        standard = 1010;
      }
    }
    
    final lowerBound = standard * 0.95;
    final upperBound = standard * 1.05;
    
    if (bmr <= lowerBound) return 1;
    if (bmr <= upperBound) return 2;
    return 3;
  }

  /// Get BMR health status text
  static String getBMRStatusText({
    required double bmr,
    required bool isMale,
    required int age,
  }) {
    final level = getBMRLevel(
      bmr: bmr,
      isMale: isMale,
      age: age,
    );
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Healthy';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  /// Get color for health level
  /// Returns color based on level: 1 = orange/red, 2 = green, 3/4 = yellow/orange
  static Color getHealthLevelColor(int level) {
    switch (level) {
      case 1:
        return Color(0xFFFF6B6B); // Light red for low/unhealthy
      case 2:
        return Color(0xFF51CF66); // Green for healthy
      case 3:
        return Color(0xFFFFC857); // Yellow/orange for slightly high
      case 4:
        return Color(0xFFE76F51); // Orange/red for dangerous
      default:
        return Colors.grey;
    }
  }
}

