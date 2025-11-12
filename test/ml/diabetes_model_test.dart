import 'package:flutter_test/flutter_test.dart';
import 'package:compositionai_ui/ml/diabetes_model.dart';
import 'package:compositionai_ui/models/user_metrics.dart';
import 'package:compositionai_ui/models/diabetes_result.dart';

void main() {
  group('DiabetesModel', () {
    test('predictDiabetesRisk returns valid result for low risk user', () {
      // Create a low-risk user profile
      final metrics = UserMetrics(
        bmi: 22.0, // Healthy BMI
        bodyFatPercent: 15.0, // Low body fat
        visceralFat: 5.0, // Low visceral fat
        muscleMass: 50.0, // Good muscle mass
        metabolicAgeDifference: -2.0, // Body age younger than actual
        weightTrend14Days: -0.5, // Losing weight
        activityScore: 0.8, // High activity
      );

      final result = DiabetesModel.predictDiabetesRisk(metrics);

      // Assertions
      expect(result.riskScore, greaterThanOrEqualTo(0.0));
      expect(result.riskScore, lessThanOrEqualTo(1.0));
      expect(result.category, RiskCategory.low);
      expect(result.confidence, greaterThanOrEqualTo(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
      expect(result.factors.length, equals(3));
    });

    test('predictDiabetesRisk returns valid result for high risk user', () {
      // Create a high-risk user profile
      final metrics = UserMetrics(
        bmi: 32.0, // Obese BMI
        bodyFatPercent: 30.0, // High body fat
        visceralFat: 15.0, // High visceral fat
        muscleMass: 35.0, // Low muscle mass
        metabolicAgeDifference: 8.0, // Body age much older
        weightTrend14Days: 2.0, // Gaining weight
        activityScore: 0.2, // Low activity
      );

      final result = DiabetesModel.predictDiabetesRisk(metrics);

      // Assertions
      expect(result.riskScore, greaterThanOrEqualTo(0.0));
      expect(result.riskScore, lessThanOrEqualTo(1.0));
      expect(result.category, RiskCategory.high);
      expect(result.confidence, greaterThanOrEqualTo(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
      expect(result.factors.length, equals(3));
    });

    test('predictDiabetesRisk returns moderate risk for middle values', () {
      // Create a moderate-risk user profile
      final metrics = UserMetrics(
        bmi: 26.0, // Overweight
        bodyFatPercent: 22.0, // Moderate body fat
        visceralFat: 10.0, // Moderate visceral fat
        muscleMass: 42.0, // Average muscle mass
        metabolicAgeDifference: 2.0, // Slightly older body age
        weightTrend14Days: 0.0, // Stable weight
        activityScore: 0.5, // Moderate activity
      );

      final result = DiabetesModel.predictDiabetesRisk(metrics);

      // Assertions
      expect(result.riskScore, greaterThanOrEqualTo(0.0));
      expect(result.riskScore, lessThanOrEqualTo(1.0));
      expect(result.category, RiskCategory.moderate);
      expect(result.confidence, greaterThanOrEqualTo(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
      expect(result.factors.length, equals(3));
    });

    test('sigmoid function handles edge cases', () {
      // Test sigmoid with very large positive value
      final largePositive = DiabetesModel.predictDiabetesRisk(
        UserMetrics(
          bmi: 50.0,
          bodyFatPercent: 50.0,
          visceralFat: 30.0,
          muscleMass: 20.0,
          metabolicAgeDifference: 20.0,
          weightTrend14Days: 10.0,
          activityScore: 0.0,
        ),
      );
      expect(largePositive.riskScore, lessThanOrEqualTo(1.0));

      // Test sigmoid with very large negative value (low risk)
      final largeNegative = DiabetesModel.predictDiabetesRisk(
        UserMetrics(
          bmi: 18.0,
          bodyFatPercent: 10.0,
          visceralFat: 1.0,
          muscleMass: 60.0,
          metabolicAgeDifference: -10.0,
          weightTrend14Days: -5.0,
          activityScore: 1.0,
        ),
      );
      expect(largeNegative.riskScore, greaterThanOrEqualTo(0.0));
    });

    test('confidence increases with distance from 0.5', () {
      final lowRisk = UserMetrics(
        bmi: 20.0,
        bodyFatPercent: 12.0,
        visceralFat: 3.0,
        muscleMass: 55.0,
        metabolicAgeDifference: -5.0,
        weightTrend14Days: -1.0,
        activityScore: 1.0,
      );

      final highRisk = UserMetrics(
        bmi: 35.0,
        bodyFatPercent: 35.0,
        visceralFat: 20.0,
        muscleMass: 30.0,
        metabolicAgeDifference: 15.0,
        weightTrend14Days: 3.0,
        activityScore: 0.1,
      );

      final lowResult = DiabetesModel.predictDiabetesRisk(lowRisk);
      final highResult = DiabetesModel.predictDiabetesRisk(highRisk);

      // Both should have reasonable confidence (far from 0.5)
      expect(lowResult.confidence, greaterThan(0.3));
      expect(highResult.confidence, greaterThan(0.3));
    });

    test('feature importance returns correct structure', () {
      final metrics = UserMetrics(
        bmi: 25.0,
        bodyFatPercent: 20.0,
        visceralFat: 8.0,
        muscleMass: 45.0,
        metabolicAgeDifference: 0.0,
        weightTrend14Days: 0.0,
        activityScore: 0.6,
      );

      final importance = DiabetesModel.getFeatureImportance(metrics);

      expect(importance.length, equals(7));
      expect(importance.containsKey('BMI'), isTrue);
      expect(importance.containsKey('Body Fat %'), isTrue);
      expect(importance.containsKey('Visceral Fat'), isTrue);
      expect(importance.containsKey('Muscle Mass'), isTrue);
      expect(importance.containsKey('Metabolic Age Difference'), isTrue);
      expect(importance.containsKey('Weight Trend (14 days)'), isTrue);
      expect(importance.containsKey('Activity Score'), isTrue);
    });

    test('toFeatureVector returns correct order and values', () {
      final metrics = UserMetrics(
        bmi: 25.5,
        bodyFatPercent: 20.5,
        visceralFat: 8.5,
        muscleMass: 45.5,
        metabolicAgeDifference: 1.5,
        weightTrend14Days: 0.5,
        activityScore: 0.65,
      );

      final features = metrics.toFeatureVector();

      expect(features.length, equals(7));
      expect(features[0], equals(25.5)); // BMI
      expect(features[1], equals(20.5)); // BodyFat%
      expect(features[2], equals(8.5)); // VisceralFat
      expect(features[3], equals(45.5)); // MuscleMass
      expect(features[4], equals(1.5)); // MetabolicAgeDifference
      expect(features[5], equals(0.5)); // WeightTrend14Days
      expect(features[6], equals(0.65)); // ActivityScore
    });

    test('DiabetesResult properties work correctly', () {
      final result = DiabetesResult(
        riskScore: 0.72,
        category: RiskCategory.high,
        confidence: 0.83,
        factors: ['High Visceral Fat', 'Rising Body Fat Trend', 'Low Activity'],
      );

      expect(result.riskPercentage, equals(72.0));
      expect(result.confidencePercentage, equals(83.0));
      expect(result.categoryName, equals('High'));
      expect(result.factors.length, equals(3));
    });
  });
}

