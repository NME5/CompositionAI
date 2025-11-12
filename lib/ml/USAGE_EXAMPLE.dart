/// Contoh penggunaan sistem prediksi risiko diabetes
///
/// Tujuan file ini:
/// - Jadi catatan cepat gimana cara manggil service/model dari berbagai layer
/// - Kasih referensi skenario umum tanpa perlu baca seluruh codebase
/// - File referensi aja, ga usah di-import ke production code
///
/// Semua contoh di bawah dikomentari supaya gak ikut ke build. Silakan copy-paste
/// ke playground / test script kalau mau coba.

// Contoh 1: Prediksi langsung pakai DataService (data user aktif)
/*
import 'package:compositionai_ui/services/diabetes_risk_service.dart';

void example1() async {
  final service = DiabetesRiskService();
  
  // Predict risk using current user data from DataService
  final result = service.predictRisk();
  
  print('Risk Score: ${result.riskScore.toStringAsFixed(2)}');
  print('Category: ${result.categoryName}');
  print('Confidence: ${result.confidencePercentage.toStringAsFixed(1)}%');
  print('Top Factors: ${result.factors.join(", ")}');
}
*/

// Contoh 2: Prediksi dengan metrics custom (tanpa data user)
/*
import 'package:compositionai_ui/services/diabetes_risk_service.dart';
import 'package:compositionai_ui/models/body_metrics.dart';
import 'package:compositionai_ui/models/user_profile.dart';

void example2() {
  final service = DiabetesRiskService();
  
  // Create custom metrics
  final metrics = BodyMetrics(
    weight: 75.0,
    muscleMass: 45.0,
    bodyFat: 22.0,
    water: 55.0,
    boneMass: 3.5,
    bmr: 1800,
  );
  
  final profile = UserProfile(
    name: 'John Doe',
    age: 35,
    height: 180,
    gender: 'Male',
    activityLevel: 'Moderately Active',
    memberSince: DateTime.now(),
  );
  
  // Predict with custom data
  final result = service.predictRisk(
    currentMetrics: metrics,
    userProfile: profile,
    hasFamilyDiabetesHistory: true,
  );
  
  print(result.toString());
}
*/

// Contoh 3: Prediksi pakai data timbangan (paling akurat)
/*
import 'package:compositionai_ui/services/diabetes_risk_service.dart';
import 'package:compositionai_ui/models/scale_reading.dart';

void example3() {
  final service = DiabetesRiskService();
  
  // Simulate a scale reading with impedance
  final reading = ScaleReading(
    weightKg: 72.5,
    impedanceOhm: 550.0,
    unitStatus: 0,
    rawHex: '',
    mfgId: 0,
  );
  
  // Predict with full impedance data (most accurate)
  final result = service.predictRiskWithImpedance(
    scaleReading: reading,
    hasFamilyDiabetesHistory: false,
  );
  
  print('Risk: ${result.riskPercentage.toStringAsFixed(1)}%');
  print('Category: ${result.categoryName}');
}
*/

// Contoh 4: Panggil model langsung (butuh akses `UserMetrics`)
/*
import 'package:compositionai_ui/ml/diabetes_model.dart';
import 'package:compositionai_ui/models/user_metrics.dart';

void example4() {
  // Create UserMetrics directly
  final metrics = UserMetrics(
    bmi: 28.5,
    bodyFatPercent: 25.0,
    visceralFat: 12.0,
    muscleMass: 40.0,
    metabolicAgeDifference: 5.0,
    weightTrend14Days: 1.5,
    activityScore: 0.3,
  );
  
  // Predict directly using the model
  final result = DiabetesModel.predictDiabetesRisk(metrics);
  
  // Get feature importance for debugging
  final importance = DiabetesModel.getFeatureImportance(metrics);
  importance.forEach((feature, contribution) {
    print('$feature: ${contribution.toStringAsFixed(3)}');
  });
}
*/

// Contoh 5: Integrasi ke ViewModel Flutter (pattern production)
/*
import 'package:flutter/material.dart';
import 'package:compositionai_ui/services/diabetes_risk_service.dart';
import 'package:compositionai_ui/models/diabetes_result.dart';

class DiabetesRiskViewModel extends ChangeNotifier {
  final DiabetesRiskService _service = DiabetesRiskService();
  DiabetesResult? _result;
  bool _isLoading = false;
  
  DiabetesResult? get result => _result;
  bool get isLoading => _isLoading;
  
  Future<void> calculateRisk() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _result = _service.predictRisk();
    } catch (e) {
      print('Error calculating risk: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
*/

