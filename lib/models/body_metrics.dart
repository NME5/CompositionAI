import 'package:hive/hive.dart';
import '../services/body_composition_calculator.dart';

// model untuk data komposisi tubuh
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

// model untuk data komposisi tubuh + datetime untk hive dan penyimpanan
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

class BodyMetricsAdapter extends TypeAdapter<BodyMetrics> {
  @override
  final int typeId = 3;

  @override
  BodyMetrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return BodyMetrics(
      weight: (fields[0] as num).toDouble(),
      muscleMass: (fields[1] as num).toDouble(),
      bodyFat: (fields[2] as num).toDouble(),
      water: (fields[3] as num).toDouble(),
      boneMass: (fields[4] as num).toDouble(),
      bmr: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMetrics obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.muscleMass)
      ..writeByte(2)
      ..write(obj.bodyFat)
      ..writeByte(3)
      ..write(obj.water)
      ..writeByte(4)
      ..write(obj.boneMass)
      ..writeByte(5)
      ..write(obj.bmr);
  }
}

/// Raw measurement data - only stores weight and calibrated impedance
/// Calculations are done on-the-fly using current calculation method
class RawMeasurementData {
  final double weightKg;
  final double calibratedImpedanceOhm; // impedance + offset

  RawMeasurementData({
    required this.weightKg,
    required this.calibratedImpedanceOhm,
  });

  /// Convert to BodyMetrics
  BodyMetrics toBodyMetrics({
    required int heightCm,
    required int age,
    required bool isMale,
  }) {
    final result = BodyCompositionCalculator.calculateAll(
      weightKg: weightKg,
      impedanceOhm: calibratedImpedanceOhm,
      heightCm: heightCm,
      age: age,
      isMale: isMale,
    );

    return BodyMetrics(
      weight: result.weightKg,
      muscleMass: result.slmKg,
      bodyFat: result.bfrPercent,
      water: result.tfrPercent,
      boneMass: result.boneMassKg,
      bmr: result.bmr.round(),
    );
  }
}

class MeasurementEntry {
  final DateTime timestamp;
  // New: store raw data (weight + calibrated impedance) instead of calculated metrics
  final RawMeasurementData? rawData;
  // Keep metrics for backward compatibility with old data
  final BodyMetrics? metrics;

  MeasurementEntry({
    required this.timestamp,
    this.rawData,
    this.metrics,
  }) : assert(rawData != null || metrics != null, 'Either rawData or metrics must be provided');

  /// Get BodyMetrics - either from stored metrics (old data) or recalculated from raw data
  BodyMetrics getBodyMetrics({
    required int heightCm,
    required int age,
    required bool isMale,
  }) {
    if (rawData != null) {
      // New format: recalculate
      return rawData!.toBodyMetrics(
        heightCm: heightCm,
        age: age,
        isMale: isMale,
      );
    }
    // Old format: return stored metrics (backward compatibility)
    return metrics!;
  }
}

class RawMeasurementDataAdapter extends TypeAdapter<RawMeasurementData> {
  @override
  final int typeId = 5;

  @override
  RawMeasurementData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return RawMeasurementData(
      weightKg: (fields[0] as num).toDouble(),
      calibratedImpedanceOhm: (fields[1] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, RawMeasurementData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weightKg)
      ..writeByte(1)
      ..write(obj.calibratedImpedanceOhm);
  }
}

class MeasurementEntryAdapter extends TypeAdapter<MeasurementEntry> {
  @override
  final int typeId = 4;

  @override
  MeasurementEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    
    // Check if this is new format (has rawData) or old format (has metrics)
    if (fields.containsKey(2)) {
      // New format: has rawData
      return MeasurementEntry(
        timestamp: fields[0] as DateTime,
        rawData: fields[2] as RawMeasurementData,
      );
    } else {
      // Old format: has metrics (backward compatibility)
      return MeasurementEntry(
        timestamp: fields[0] as DateTime,
        metrics: fields[1] as BodyMetrics,
      );
    }
  }

  @override
  void write(BinaryWriter writer, MeasurementEntry obj) {
    if (obj.rawData != null) {
      // New format: write rawData
      writer
        ..writeByte(2)
        ..writeByte(0)
        ..write(obj.timestamp)
        ..writeByte(2)
        ..write(obj.rawData);
    } else {
      // Old format: write metrics (for backward compatibility)
      writer
        ..writeByte(2)
        ..writeByte(0)
        ..write(obj.timestamp)
        ..writeByte(1)
        ..write(obj.metrics);
    }
  }
}

