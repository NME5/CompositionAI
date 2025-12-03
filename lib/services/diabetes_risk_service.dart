import '../models/user_metrics.dart';
import '../models/diabetes_result.dart';
import '../models/body_metrics.dart';
import '../models/user_profile.dart';
import '../models/scale_reading.dart';
import '../ml/diabetes_model.dart';
import '../services/body_composition_calculator.dart';
import '../services/data_service.dart';

/// Service for calculating diabetes risk predictions
/// 
/// Integrates with DataService to gather user metrics and historical data,
/// then uses DiabetesModel to predict risk.
/// 
/// This service handles:
/// - Extracting features from user profile and body metrics
/// - Calculating trend data from historical measurements
/// - Normalizing activity levels to scores
/// - Calling the prediction model
class DiabetesRiskService {
  final DataService _dataService = DataService();

  /// Predict diabetes risk for the current user
  /// 
  /// Gathers all necessary data from DataService and calculates risk.
  /// 
  /// [currentMetrics] - Optional current body metrics (if null, uses latest from history)
  /// [userProfile] - Optional user profile (if null, fetches from DataService)
  /// [hasFamilyDiabetesHistory] - Optional family history flag
  /// 
  /// Returns DiabetesResult with prediction
  DiabetesResult predictRisk({
    BodyMetrics? currentMetrics,
    UserProfile? userProfile,
    bool? hasFamilyDiabetesHistory,
  }) {
    // Get user profile
    final profile = userProfile ?? _dataService.getUserProfile();

    // Get current metrics
    final metrics = currentMetrics ?? _getCurrentMetrics();

    // Get historical measurements for trend calculation
    final measurements = _dataService.getAllMeasurements();

    // Calculate BMI
    final bmi = BodyCompositionCalculator.calculateBMI(
      profile.height.toInt(),
      metrics.weight,
    );

    // Calculate visceral fat (requires impedance - we'll estimate or use default)
    // Note: In a real scenario, you'd need impedance from the scale reading
    // For now, we'll use a default or calculate from available data
    final visceralFat = _estimateVisceralFat(
      profile: profile,
      metrics: metrics,
    );

    // Calculate metabolic age difference
    final metabolicAgeDifference = _calculateMetabolicAgeDifference(
      profile: profile,
      metrics: metrics,
    );

    // Calculate weight trend over 14 days
    final weightTrend14Days = _calculateWeightTrend14Days(measurements);

    // Convert activity level to score
    final activityScore = _activityLevelToScore(profile.activityLevel);

    // Create UserMetrics
    final userMetrics = UserMetrics(
      bmi: bmi,
      bodyFatPercent: metrics.bodyFat,
      visceralFat: visceralFat,
      muscleMass: metrics.muscleMass,
      metabolicAgeDifference: metabolicAgeDifference,
      weightTrend14Days: weightTrend14Days,
      activityScore: activityScore,
      hasFamilyDiabetesHistory: hasFamilyDiabetesHistory,
    );

    // Predict risk
    return DiabetesModel.predictDiabetesRisk(userMetrics);
  }

  /// Get current metrics from the most recent measurement
  BodyMetrics _getCurrentMetrics() {
    final measurements = _dataService.getAllMeasurements();
    if (measurements.isNotEmpty) {
      // Sort by timestamp and get most recent
      measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final profile = _dataService.getUserProfile();
      final isMale = profile.gender.toLowerCase().startsWith('m');
      return measurements.first.getBodyMetrics(
        heightCm: profile.height.round(),
        age: profile.age,
        isMale: isMale,
      );
    }
    // Fallback to default current metrics
    return _dataService.getCurrentMetrics();
  }

  /// Estimate visceral fat when impedance is not available
  /// 
  /// Uses a simplified estimation based on BMI and body fat percentage.
  /// In production, this should use actual impedance data from scale readings.
  double _estimateVisceralFat({
    required UserProfile profile,
    required BodyMetrics metrics,
  }) {
    // Simplified estimation: VFR correlates with BMI and body fat
    // This is a rough approximation - ideally use actual impedance
    final bmi = BodyCompositionCalculator.calculateBMI(
      profile.height.toInt(),
      metrics.weight,
    );

    // Rough estimation: higher BMI and body fat = higher visceral fat
    // Formula: VFR ≈ (BMI * 0.5) + (bodyFat * 0.3) + base
    final estimated = (bmi * 0.5) + (metrics.bodyFat * 0.3) + 5.0;
    return estimated.clamp(1.0, 59.0);
  }

  /// Calculate metabolic age difference (bodyAge - actualAge)
  /// 
  /// Positive values indicate body age is older than chronological age.
  double _calculateMetabolicAgeDifference({
    required UserProfile profile,
    required BodyMetrics metrics,
  }) {
    // Estimate body age using BMI and body composition
    // In production, use actual impedance to calculate precise body age
    final bmi = BodyCompositionCalculator.calculateBMI(
      profile.height.toInt(),
      metrics.weight,
    );

    // Simplified estimation: higher BMI and body fat = older metabolic age
    // Formula: bodyAge ≈ actualAge + (BMI - 22) * 0.5 + (bodyFat - 15) * 0.3
    final estimatedBodyAge = profile.age +
        ((bmi - 22.0) * 0.5) +
        ((metrics.bodyFat - 15.0) * 0.3);

    return estimatedBodyAge - profile.age.toDouble();
  }

  /// Calculate weight trend over the last 14 days
  /// 
  /// Returns the change in weight (kg) over 14 days.
  /// Positive values indicate weight gain, negative indicates weight loss.
  double _calculateWeightTrend14Days(List<MeasurementEntry> measurements) {
    if (measurements.isEmpty) {
      return 0.0;
    }

    // Sort by timestamp (most recent first)
    measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final now = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    // Find measurements within the last 14 days
    final recentMeasurements = measurements
        .where((m) => m.timestamp.isAfter(fourteenDaysAgo))
        .toList();

    if (recentMeasurements.length < 2) {
      // Not enough data for trend - return 0
      return 0.0;
    }

    // Get oldest and newest weights in the period
    recentMeasurements.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final profile = _dataService.getUserProfile();
    final isMale = profile.gender.toLowerCase().startsWith('m');
    
    final oldestMetrics = recentMeasurements.first.getBodyMetrics(
      heightCm: profile.height.round(),
      age: profile.age,
      isMale: isMale,
    );
    final newestMetrics = recentMeasurements.last.getBodyMetrics(
      heightCm: profile.height.round(),
      age: profile.age,
      isMale: isMale,
    );
    
    final oldestWeight = oldestMetrics.weight;
    final newestWeight = newestMetrics.weight;

    // Calculate trend (positive = weight gain, negative = weight loss)
    return newestWeight - oldestWeight;
  }

  /// Convert activity level string to numeric score (0.0-1.0)
  /// 
  /// [activityLevel] - Activity level string from user profile
  /// 
  /// Returns score between 0.0 (low) and 1.0 (high)
  double _activityLevelToScore(String activityLevel) {
    final level = activityLevel.toLowerCase();

    if (level.contains('low') || level.contains('sedentary')) {
      return 0.2;
    } else if (level.contains('moderate') || level.contains('moderately')) {
      return 0.5;
    } else if (level.contains('active') || level.contains('high')) {
      return 0.8;
    } else if (level.contains('very') || level.contains('extremely')) {
      return 1.0;
    }

    // Default to moderate
    return 0.5;
  }

  /// Predict risk with full impedance data (more accurate)
  /// 
  /// Use this method when you have a complete scale reading with impedance.
  /// 
  /// [scaleReading] - Scale reading with weight and impedance
  /// [userProfile] - Optional user profile
  /// [hasFamilyDiabetesHistory] - Optional family history flag
  /// 
  /// Returns DiabetesResult with more accurate prediction
  DiabetesResult predictRiskWithImpedance({
    required ScaleReading scaleReading,
    UserProfile? userProfile,
    bool? hasFamilyDiabetesHistory,
  }) {
    if (!scaleReading.hasValidWeight || !scaleReading.hasValidImpedance) {
      throw ArgumentError('Scale reading must have valid weight and impedance');
    }

    final profile = userProfile ?? _dataService.getUserProfile();
    final measurements = _dataService.getAllMeasurements();

    // Calculate all body composition metrics using actual impedance
    final composition = BodyCompositionCalculator.calculateAll(
      weightKg: scaleReading.weightKg!,
      impedanceOhm: scaleReading.impedanceOhm,
      heightCm: profile.height.toInt(),
      age: profile.age,
      isMale: profile.gender.toLowerCase() == 'male',
    );

    // Calculate weight trend
    final weightTrend14Days = _calculateWeightTrend14Days(measurements);

    // Activity score
    final activityScore = _activityLevelToScore(profile.activityLevel);

    // Metabolic age difference
    final metabolicAgeDifference =
        composition.bodyAge.toDouble() - profile.age.toDouble();

    // Create UserMetrics with accurate data
    final userMetrics = UserMetrics(
      bmi: composition.bmi,
      bodyFatPercent: composition.bfrPercent,
      visceralFat: composition.vfr,
      muscleMass: composition.slmKg,
      metabolicAgeDifference: metabolicAgeDifference,
      weightTrend14Days: weightTrend14Days,
      activityScore: activityScore,
      hasFamilyDiabetesHistory: hasFamilyDiabetesHistory,
    );

    return DiabetesModel.predictDiabetesRisk(userMetrics);
  }
}

