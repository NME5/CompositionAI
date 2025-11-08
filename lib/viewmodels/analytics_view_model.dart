import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/body_metrics.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final List<String> _periods = ['7D', '1M', '3M', '1Y'];
  String _selectedPeriod = '7D';
  final DataService _dataService = DataService();

  List<MeasurementEntry> _allMeasurements = [];

  String get selectedPeriod => _selectedPeriod;

  BodyMetrics? get currentMetrics {
    if (_allMeasurements.isNotEmpty) {
      return _allMeasurements.last.metrics;
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
    // Plot body fat percentage as 0..1
    return List.generate(filtered.length, (i) {
      final m = filtered[i];
      final y = (m.metrics.bodyFat) / 100.0;
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
    final delta = _deltaFor((m) => m.metrics.bodyFat);
    if (delta == null) return '';
    final arrow = delta >= 0 ? '↑' : '↓';
    return '$arrow ${delta.abs().toStringAsFixed(1)}%';
  }

  // Expose other metric values and deltas
  String get muscleMassText => _formatNumber(currentMetrics?.muscleMass, suffix: '%');
  String get muscleDeltaText => _formatDelta(_deltaFor((m) => m.metrics.muscleMass), suffix: '%');
  String get waterText => _formatNumber(currentMetrics?.water, suffix: '%');
  String get waterDeltaText => _formatDelta(_deltaFor((m) => m.metrics.water), suffix: '%');
  String get boneMassText => _formatNumber(currentMetrics?.boneMass, suffix: 'kg');
  String get boneDeltaText => _formatDelta(_deltaFor((m) => m.metrics.boneMass), suffix: 'kg');
  String get bmrText => _formatNumber(currentMetrics?.bmr.toDouble(), fractionDigits: 0);
  String get bmrDeltaText => _formatDelta(_deltaFor((m) => m.metrics.bmr.toDouble()), fractionDigits: 0);

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

