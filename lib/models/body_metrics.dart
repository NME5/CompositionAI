import 'package:hive/hive.dart';

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

class MeasurementEntry {
  final DateTime timestamp;
  final BodyMetrics metrics;

  MeasurementEntry({
    required this.timestamp,
    required this.metrics,
  });
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
    return MeasurementEntry(
      timestamp: fields[0] as DateTime,
      metrics: fields[1] as BodyMetrics,
    );
  }

  @override
  void write(BinaryWriter writer, MeasurementEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.metrics);
  }
}

