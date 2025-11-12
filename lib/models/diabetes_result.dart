/// Risk category for diabetes prediction
enum RiskCategory {
  low,
  moderate,
  high,
}

/// Diabetes risk prediction result
/// 
/// Contains the predicted risk score, category, confidence,
/// and contributing factors that influenced the prediction.
class DiabetesResult {
  /// Risk score between 0.0 and 1.0
  /// 0.0 = very low risk, 1.0 = very high risk
  final double riskScore;

  /// Risk category based on score thresholds
  final RiskCategory category;

  /// Confidence score (0.0-1.0)
  /// Higher values indicate the model is more confident in its prediction
  /// Calculated as distance from 0.5 (the decision boundary)
  final double confidence;

  /// Top 3 contributing factors that increased risk
  /// Ordered by impact (highest impact first)
  final List<String> factors;

  DiabetesResult({
    required this.riskScore,
    required this.category,
    required this.confidence,
    required this.factors,
  });

  /// Get risk score as percentage
  double get riskPercentage => riskScore * 100.0;

  /// Get confidence as percentage
  double get confidencePercentage => confidence * 100.0;

  /// Get category display name
  String get categoryName {
    switch (category) {
      case RiskCategory.low:
        return 'Low';
      case RiskCategory.moderate:
        return 'Moderate';
      case RiskCategory.high:
        return 'High';
    }
  }

  @override
  String toString() {
    return 'DiabetesResult('
        'riskScore: ${riskScore.toStringAsFixed(2)}, '
        'category: $categoryName, '
        'confidence: ${confidence.toStringAsFixed(2)}, '
        'factors: $factors'
        ')';
  }
}

