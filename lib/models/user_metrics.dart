/// UserMetrics model for diabetes risk prediction
/// 
/// Combines body composition metrics, profile data, and trend information
/// required for the diabetes risk prediction model.
class UserMetrics {
  /// Body Mass Index
  final double bmi;

  /// Body Fat Percentage (0-100)
  final double bodyFatPercent;

  /// Visceral Fat Rating (1-59)
  final double visceralFat;

  /// Muscle Mass in kilograms
  final double muscleMass;

  /// Metabolic Age Difference (bodyAge - actualAge)
  /// Positive values indicate body age is older than chronological age
  final double metabolicAgeDifference;

  /// Weight Trend over 14 days in kilograms
  /// Positive values indicate weight gain, negative indicates weight loss
  final double weightTrend14Days;

  /// Activity Score (0.0-1.0)
  /// 0.0 = Low activity, 0.5 = Moderate, 1.0 = High activity
  final double activityScore;

  /// Optional: Family diabetes history
  final bool? hasFamilyDiabetesHistory;

  UserMetrics({
    required this.bmi,
    required this.bodyFatPercent,
    required this.visceralFat,
    required this.muscleMass,
    required this.metabolicAgeDifference,
    required this.weightTrend14Days,
    required this.activityScore,
    this.hasFamilyDiabetesHistory,
  });

  /// Convert to feature vector for model prediction
  /// Returns list of features in the order expected by the model
  List<double> toFeatureVector() {
    return [
      bmi,
      bodyFatPercent,
      visceralFat,
      muscleMass,
      metabolicAgeDifference,
      weightTrend14Days,
      activityScore,
    ];
  }

  @override
  String toString() {
    return 'UserMetrics('
        'BMI: ${bmi.toStringAsFixed(1)}, '
        'BodyFat: ${bodyFatPercent.toStringAsFixed(1)}%, '
        'VisceralFat: ${visceralFat.toStringAsFixed(1)}, '
        'MuscleMass: ${muscleMass.toStringAsFixed(1)}kg, '
        'MetabolicAgeDiff: ${metabolicAgeDifference.toStringAsFixed(1)}, '
        'WeightTrend14d: ${weightTrend14Days.toStringAsFixed(2)}kg, '
        'ActivityScore: ${activityScore.toStringAsFixed(2)}'
        ')';
  }
}

