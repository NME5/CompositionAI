class BodyMetrics {
  final double weight;
  final double muscleMass;
  final double bodyFat;
  final double water;
  final double boneMass;
  final int bmr;

  BodyMetrics({
    required this.weight,
    required this.muscleMass,
    required this.bodyFat,
    required this.water,
    required this.boneMass,
    required this.bmr,
  });
}

class MeasurementData {
  final DateTime dateTime;
  final BodyMetrics metrics;
  final double previousFat;

  MeasurementData({
    required this.dateTime,
    required this.metrics,
    required this.previousFat,
  });

  double get fatChange => metrics.bodyFat - previousFat;
  bool get isImproving => fatChange < 0;
}

