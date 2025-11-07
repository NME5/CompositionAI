import 'package:flutter/material.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final List<String> _periods = ['7D', '1M', '3M', '1Y'];
  String _selectedPeriod = '7D';

  String get selectedPeriod => _selectedPeriod;

  void selectPeriod(String period) {
    if (_periods.contains(period) && period != _selectedPeriod) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  List<Map<String, num>> get chartData {
    switch (_selectedPeriod) {
      case '1M':
        return [
          {'x': 0, 'y': 0.82},
          {'x': 1, 'y': 0.8},
          {'x': 2, 'y': 0.79},
          {'x': 3, 'y': 0.78},
          {'x': 4, 'y': 0.77},
          {'x': 5, 'y': 0.75},
        ];
      case '3M':
        return [
          {'x': 0, 'y': 0.88},
          {'x': 1, 'y': 0.87},
          {'x': 2, 'y': 0.86},
          {'x': 3, 'y': 0.84},
          {'x': 4, 'y': 0.83},
          {'x': 5, 'y': 0.81},
          {'x': 6, 'y': 0.8},
          {'x': 7, 'y': 0.79},
        ];
      case '1Y':
        return [
          {'x': 0, 'y': 0.95},
          {'x': 1, 'y': 0.93},
          {'x': 2, 'y': 0.91},
          {'x': 3, 'y': 0.89},
          {'x': 4, 'y': 0.87},
          {'x': 5, 'y': 0.85},
          {'x': 6, 'y': 0.83},
          {'x': 7, 'y': 0.82},
          {'x': 8, 'y': 0.81},
          {'x': 9, 'y': 0.8},
          {'x': 10, 'y': 0.79},
          {'x': 11, 'y': 0.78},
        ];
      case '7D':
      default:
        return [
          {'x': 0, 'y': 0.8},
          {'x': 1, 'y': 0.7},
          {'x': 2, 'y': 0.65},
          {'x': 3, 'y': 0.6},
          {'x': 4, 'y': 0.58},
          {'x': 5, 'y': 0.52},
          {'x': 6, 'y': 0.5},
        ];
    }
  }

  List<String> get xAxisLabels {
    switch (_selectedPeriod) {
      case '1M':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Today'];
      case '3M':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6', 'Week 7', 'Today'];
      case '1Y':
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      case '7D':
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }
}

