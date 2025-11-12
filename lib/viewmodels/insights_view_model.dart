import 'package:flutter/material.dart';

import '../models/diabetes_result.dart';
import '../services/diabetes_risk_service.dart';

class InsightsViewModel extends ChangeNotifier {
  final DiabetesRiskService _riskService = DiabetesRiskService();

  String _selectedFilter = 'All';
  bool _isLoadingAi = false;
  DiabetesResult? _latestResult;
  Object? _aiError;
  DateTime? _lastUpdated;

  String get selectedFilter => _selectedFilter;
  bool get isLoadingAi => _isLoadingAi;
  DiabetesResult? get latestResult => _latestResult;
  Object? get aiError => _aiError;
  DateTime? get lastUpdated => _lastUpdated;

  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadAiInsights() async {
    if (_isLoadingAi) {
      return;
    }

    _isLoadingAi = true;
    notifyListeners();

    try {
      final result = await Future<DiabetesResult>.microtask(
        () => _riskService.predictRisk(),
      );
      _latestResult = result;
      _aiError = null;
      _lastUpdated = DateTime.now();
    } catch (error) {
      _aiError = error;
    } finally {
      _isLoadingAi = false;
      notifyListeners();
    }
  }
}

