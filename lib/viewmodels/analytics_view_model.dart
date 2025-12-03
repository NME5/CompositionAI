import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/body_composition_calculator.dart';
import '../models/body_metrics.dart';
import '../models/user_profile.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final List<String> _periods = ['7D', '1M', '3M', '1Y'];
  String _selectedPeriod = '7D';
  final DataService _dataService = DataService();

  List<MeasurementEntry> _allMeasurements = [];

  String get selectedPeriod => _selectedPeriod;

  BodyMetrics? get currentMetrics {
    if (_allMeasurements.isNotEmpty) {
      final profile = _userProfile;
      if (profile == null) return null;
      final isMale = profile.gender.toLowerCase().startsWith('m');
      return _allMeasurements.last.getBodyMetrics(
        heightCm: profile.height.round(),
        age: profile.age,
        isMale: isMale,
      );
    }
    // Fallback to current metrics if no history yet
    return _dataService.getCurrentMetrics();
  }

  Future<void> load() async {
    // Synchronous Hive read; keep API async for future-proofing
    final list = _dataService.getAllMeasurements();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _allMeasurements = list;
    notifyListeners();
  }

  void selectPeriod(String period) {
    if (_periods.contains(period) && period != _selectedPeriod) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  List<Map<String, num>> get chartData {
    final filtered = _filteredMeasurementsForSelectedPeriod();
    if (filtered.isEmpty) return [];
    final profile = _userProfile;
    if (profile == null) return [];
    final isMale = profile.gender.toLowerCase().startsWith('m');
    
    // Plot body fat percentage as 0..1
    return List.generate(filtered.length, (i) {
      final m = filtered[i];
      final metrics = m.getBodyMetrics(
        heightCm: profile.height.round(),
        age: profile.age,
        isMale: isMale,
      );
      final y = (metrics.bodyFat) / 100.0;
      return {'x': i, 'y': y};
    });
  }

  List<String> get xAxisLabels {
    final filtered = _filteredMeasurementsForSelectedPeriod();
    if (filtered.isEmpty) return [];
    return filtered.map((m) => _formatShortDate(m.timestamp)).toList();
  }

  String get bodyFatPercentText {
    final cm = currentMetrics;
    if (cm == null) return '--';
    return '${cm.bodyFat.toStringAsFixed(1)}%';
  }

  String get bodyFatDeltaText {
    final delta = _deltaFor((m) {
      final profile = _userProfile;
      if (profile == null) return 0.0;
      final isMale = profile.gender.toLowerCase().startsWith('m');
      final metrics = m.getBodyMetrics(
        heightCm: profile.height.round(),
        age: profile.age,
        isMale: isMale,
      );
      return metrics.bodyFat;
    });
    if (delta == null) return '';
    final arrow = delta >= 0 ? '↑' : '↓';
    return '$arrow ${delta.abs().toStringAsFixed(1)}%';
  }

  // Expose other metric values and deltas
  String get muscleMassText => _formatNumber(currentMetrics?.muscleMass, suffix: '%');
  String get muscleDeltaText => _formatDelta(_deltaFor((m) {
    final profile = _userProfile;
    if (profile == null) return 0.0;
    final isMale = profile.gender.toLowerCase().startsWith('m');
    final metrics = m.getBodyMetrics(
      heightCm: profile.height.round(),
      age: profile.age,
      isMale: isMale,
    );
    return metrics.muscleMass;
  }), suffix: '%');
  double? get muscleMassProgress => currentMetrics?.muscleMass != null ? (currentMetrics!.muscleMass / 100.0).clamp(0.0, 1.0) : null;
  
  String get waterText => _formatNumber(currentMetrics?.water, suffix: '%');
  String get waterDeltaText => _formatDelta(_deltaFor((m) {
    final profile = _userProfile;
    if (profile == null) return 0.0;
    final isMale = profile.gender.toLowerCase().startsWith('m');
    final metrics = m.getBodyMetrics(
      heightCm: profile.height.round(),
      age: profile.age,
      isMale: isMale,
    );
    return metrics.water;
  }), suffix: '%');
  double? get waterProgress => currentMetrics?.water != null ? (currentMetrics!.water / 100.0).clamp(0.0, 1.0) : null;
  
  String get bodyFatText => bodyFatPercentText;
  String get bodyFatDeltaCardText => bodyFatDeltaText.isEmpty ? '—' : bodyFatDeltaText;
  double? get bodyFatProgress => currentMetrics?.bodyFat != null ? (currentMetrics!.bodyFat / 100.0).clamp(0.0, 1.0) : null;

  String get boneMassText => _formatNumber(currentMetrics?.boneMass, suffix: 'kg');
  String get boneDeltaText => _formatDelta(_deltaFor((m) {
    final profile = _userProfile;
    if (profile == null) return 0.0;
    final isMale = profile.gender.toLowerCase().startsWith('m');
    final metrics = m.getBodyMetrics(
      heightCm: profile.height.round(),
      age: profile.age,
      isMale: isMale,
    );
    return metrics.boneMass;
  }), suffix: 'kg');
  // Bone mass as percentage of body weight (typically 2-5%), normalize to 0-10% range for progress
  double? get boneMassProgress {
    if (currentMetrics == null) return null;
    final weight = currentMetrics!.weight;
    if (weight <= 0) return null;
    // Calculate bone mass as percentage: (boneMass / weight) * 100
    final bonePercent = (currentMetrics!.boneMass / weight) * 100.0;
    // Normalize to 0-10% range to avoid maxing out, clamp to 0-1
    return (bonePercent / 10.0).clamp(0.0, 1.0);
  }
  
  String get bmrText => _formatNumber(currentMetrics?.bmr.toDouble(), fractionDigits: 0);
  String get bmrDeltaText => _formatDelta(_deltaFor((m) {
    final profile = _userProfile;
    if (profile == null) return 0.0;
    final isMale = profile.gender.toLowerCase().startsWith('m');
    final metrics = m.getBodyMetrics(
      heightCm: profile.height.round(),
      age: profile.age,
      isMale: isMale,
    );
    return metrics.bmr.toDouble();
  }), fractionDigits: 0);
  // BMR typically ranges from 1200-3000 kcal, normalize to this range
  double? get bmrProgress {
    if (currentMetrics == null) return null;
    final bmr = currentMetrics!.bmr.toDouble();
    // Normalize to 1200-3000 range, clamp to 0-1
    return ((bmr - 1200) / (3000 - 1200)).clamp(0.0, 1.0);
  }

  // Helpers
  List<MeasurementEntry> _filteredMeasurementsForSelectedPeriod() {
    if (_allMeasurements.isEmpty) return [];
    final now = DateTime.now();
    DateTime start;
    switch (_selectedPeriod) {
      case '1M':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3M':
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case '1Y':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      case '7D':
      default:
        start = now.subtract(Duration(days: 7));
        break;
    }
    final list = _allMeasurements.where((m) => !m.timestamp.isBefore(start)).toList();
    if (list.isEmpty) return _allMeasurements.length <= 20 ? _allMeasurements : _allMeasurements.sublist(_allMeasurements.length - 20);
    return list;
  }

  double? _deltaFor(double Function(MeasurementEntry) selector) {
    final filtered = _filteredMeasurementsForSelectedPeriod();
    if (filtered.isEmpty) return null;
    final first = selector(filtered.first);
    final last = selector(filtered.last);
    return last - first;
  }

  // BMI calculations
  String get bmiText {
    final bmi = _currentBMI;
    if (bmi == null) return '--';
    return bmi.toStringAsFixed(1);
  }

  String get bmiDeltaText {
    final profile = _userProfile;
    final heightCm = profile?.height ?? 0;
    if (heightCm <= 0 || profile == null) return '';
    final isMale = profile.gender.toLowerCase().startsWith('m');
    final delta = _deltaFor(
      (entry) {
        final metrics = entry.getBodyMetrics(
          heightCm: profile.height.round(),
          age: profile.age,
          isMale: isMale,
        );
        return BodyCompositionCalculator.calculateBMI(heightCm.round(), metrics.weight);
      },
    );
    return _formatDelta(delta, fractionDigits: 1);
  }

  double? get bmiProgress {
    final bmi = _currentBMI;
    if (bmi == null) return null;
    // Normalize BMI to 15-40 range
    return ((bmi - 15.0) / (40.0 - 15.0)).clamp(0.0, 1.0);
  }

  double? get _currentBMI {
    final metrics = currentMetrics;
    final heightCm = _userProfile?.height ?? 0;
    if (metrics == null || heightCm <= 0) return null;
    return BodyCompositionCalculator.calculateBMI(heightCm.round(), metrics.weight);
  }

  UserProfile? get _userProfile {
    try {
      return _dataService.getUserProfile();
    } catch (_) {
      return null;
    }
  }

  String _formatShortDate(DateTime dt) {
    // Format as M/d or d MMM depending on period
    final isYear = _selectedPeriod == '1Y';
    if (isYear) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return months[dt.month - 1];
    }
    return '${dt.month}/${dt.day}';
  }

  String _formatNumber(double? value, {String suffix = '', int fractionDigits = 1}) {
    if (value == null) return '--';
    return '${value.toStringAsFixed(fractionDigits)}${suffix.isNotEmpty ? ' $suffix' : ''}';
    }

  String _formatDelta(double? delta, {String suffix = '', int fractionDigits = 1}) {
    if (delta == null) return '';
    final arrow = delta >= 0 ? '↑' : '↓';
    return '$arrow ${delta.abs().toStringAsFixed(fractionDigits)}${suffix.isNotEmpty ? ' $suffix' : ''}';
  }
}

