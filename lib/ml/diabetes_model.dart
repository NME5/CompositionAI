import '../models/user_metrics.dart';
import '../models/diabetes_result.dart';
import 'model_weights.dart';
import 'dart:math' as math;

/// Bayesian Logistic Regression model for diabetes risk prediction
/// 
/// Author: Timothy Juwono
/// 
/// Model ini jalan on-device menggunakan perhitungan logistic reggresion dengan manual (tanpa tensor)
/// Model ini mengimplementasi fungsi sigmoid dan weighted sum calculation.
/// 
/// Formula: risk = 1 / (1 + e^-(b0 + b1*x1 + b2*x2 + ...))
/// 
/// Model ini dirancang untuk:
/// - Fully offline (tanpa API calls, menggunakan perhitungan manual)
/// - Numerically stable (menggunakan perhitungan matematika yang stabil)
/// - Lightweight (tanpa tensorflow yang berat)
/// - Mudah untuk diupdate dengan weight baru
class DiabetesModel {
  /// Prediksi risiko diabetes dari metrics user
  /// 
  /// [metrics] - Object UserMetrics mempunyai semua required features
  /// 
  /// Returns DiabetesResult dengan risk score, category, confidence, dan factors
  static DiabetesResult predictDiabetesRisk(UserMetrics metrics) {
    // Validate weights
    if (!DiabetesModelWeights.isValid) {
      throw StateError('Model weights are invalid: weights and names count mismatch');
    }

    // Get feature vector
    final features = metrics.toFeatureVector();
    if (features.length != DiabetesModelWeights.featureCount) {
      throw ArgumentError(
        'Feature count mismatch: expected ${DiabetesModelWeights.featureCount}, got ${features.length}',
      );
    }

    // Kalkulasi weighted sum: b0 + b1*x1 + b2*x2 + ...
    final weightedSum = _calculateWeightedSum(features);

    // Apply sigmoid function with numerical stability
    final riskScore = _sigmoid(weightedSum);

    // Tentukan risk category
    final category = _categorizeRisk(riskScore);

    // Kalkulasi confidence (distance from 0.5 decision boundary)
    final confidence = _calculateConfidence(riskScore);

    // Identify top contributing factors
    final factors = _identifyContributingFactors(features, riskScore);

    return DiabetesResult(
      riskScore: riskScore,
      category: category,
      confidence: confidence,
      factors: factors,
    );
  }

  /// Kalkulasi weighted sum: intercept + sum(weight_i * feature_i)
  /// 
  /// [features] - Feature vector in the correct order
  /// 
  /// Returns the linear combination before sigmoid
  static double _calculateWeightedSum(List<double> features) {
    double sum = DiabetesModelWeights.intercept;

    for (int i = 0; i < features.length; i++) {
      final normalized = _normalizeFeature(features[i], i);
      sum += DiabetesModelWeights.featureWeights[i] * normalized;
    }

    return sum;
  }

  /// Normalisasi fitur ke skala training (z-score)
  static double _normalizeFeature(double value, int index) {
    final mean = DiabetesModelWeights.featureMeans[index];
    final std = DiabetesModelWeights.featureStdDevs[index];
    if (std == 0) {
      return 0.0;
    }
    return (value - mean) / std;
  }

  /// Sigmoid function: 1 / (1 + e^(-x))
  /// 
  /// Menggunakan numerically stable implementation untuk menghindari overflow.
  /// Untuk value negatif besar, gunakan: 1 / (1 + e^x) dimana x adalah positive
  /// 
  /// [x] - The weighted sum value
  /// 
  /// Returns probability diantara 0.0 dan 1.0
  static double _sigmoid(double x) {
    // Numerical stability: hindari overflow for large positive x
    if (x > 20) {
      return 1.0;
    }
    // For large negative x, gunakan formula alternatif
    if (x < -20) {
      return 0.0;
    }

    // Standard sigmoid: 1 / (1 + e^(-x))
    return 1.0 / (1.0 + math.exp(-x));
  }

  /// Kategori risiko berdasarkan score thresholds
  /// 
  /// [riskScore] - Risk score diantara 0.0 dan 1.0
  /// 
  /// Returns RiskCategory
  static RiskCategory _categorizeRisk(double riskScore) {
    if (riskScore < 0.3) {
      return RiskCategory.low;
    } else if (riskScore < 0.7) {
      return RiskCategory.moderate;
    } else {
      return RiskCategory.high;
    }
  }

  /// Calculate confidence score berdasarkan distance from decision boundary (0.5)
  /// 
  /// Confidence is higher when the score is further from 0.5.
  /// Formula: confidence = 2 * |riskScore - 0.5|
  /// 
  /// [riskScore] - Risk score between 0.0 and 1.0
  /// 
  /// Returns confidence between 0.0 and 1.0
  static double _calculateConfidence(double riskScore) {
    // Distance from 0.5 (decision boundary)
    final distance = (riskScore - 0.5).abs();
    // Scale to 0-1 range (max distance is 0.5, so multiply by 2)
    return (distance * 2.0).clamp(0.0, 1.0);
  }

  /// Identifikasi top 3 factor yang berkontribusi meningkatkan risiko
  /// 
  /// Kalkulasi kontribusi tiap fitur yg berpengaruh ke risk score
  /// Dan returns top 3 factor yang meningkatkan risiko yang paling besar.
  /// 
  /// [features] - Feature vector
  /// [riskScore] - Predicted risk score
  /// 
  /// Returns list of factor descriptions ordered by impact
  static List<String> _identifyContributingFactors(
    List<double> features,
    double riskScore,
  ) {
    // Calculate contribution of each feature
    // Contribution = weight * feature_value (only positive contributions increase risk)
    final contributions = <MapEntry<String, double>>[];

    for (int i = 0; i < features.length; i++) {
      final weight = DiabetesModelWeights.featureWeights[i];
      final featureValue = features[i];
      final normalizedValue = _normalizeFeature(featureValue, i);
      final contribution = weight * normalizedValue;

      // Hanya mempertimbangkan factor yang meningkatkan risiko (kontribusi positif)
      // Untuk berat negatif (seperti muscle mass, activity), dicek jika
      // value fitur adalah rendah (yang akan meningkatkan risiko)
      String factorName = DiabetesModelWeights.featureNames[i];
      double impact = 0.0;

      if (weight > 0) {
        // Positive weight: nilai di atas rata-rata (z > 0) = risiko lebih tinggi
        if (normalizedValue > 0) {
          impact = contribution;
        }
      } else {
        // Negative weight: nilai di bawah rata-rata (z < 0) = risiko lebih tinggi
        if (normalizedValue < 0) {
          impact = contribution.abs();
          factorName = 'Low ${factorName}';
        }
      }

      if (impact > 0) {
        contributions.add(MapEntry(factorName, impact));
      }
    }

    // Urutkan berdasarkan impact (descending) dan ambil top 3
    contributions.sort((a, b) => b.value.compareTo(a.value));
    final topFactors = contributions.take(3).map((e) => e.key).toList();

    // Jika tidak ada 3 factor, tambahkan generic ones
    while (topFactors.length < 3) {
      if (riskScore > 0.5) {
        topFactors.add('Elevated Risk Factors');
      } else {
        topFactors.add('Monitor Health Metrics');
      }
    }

    return topFactors;
  }

  /// Get feature importance scores untuk semua fitur
  /// 
  /// Digunakan untuk debugging dan memahami behavior model
  /// 
  /// [metrics] - UserMetrics object
  /// 
  /// Returns map of feature names to their contribution values
  static Map<String, double> getFeatureImportance(UserMetrics metrics) {
    final features = metrics.toFeatureVector();
    final importance = <String, double>{};

    for (int i = 0; i < features.length; i++) {
      final weight = DiabetesModelWeights.featureWeights[i];
      final normalizedValue = _normalizeFeature(features[i], i);
      final contribution = weight * normalizedValue;
      importance[DiabetesModelWeights.featureNames[i]] = contribution;
    }

    return importance;
  }
}

