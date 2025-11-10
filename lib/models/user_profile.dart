import 'package:hive/hive.dart';

class UserProfile {
  final String name;
  int age;
  double height;
  String gender;
  String activityLevel;
  final DateTime memberSince;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.memberSince,
  });

  // Copy with method for creating updated instances
  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    String? gender,
    String? activityLevel,
    DateTime? memberSince,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

class UserStats {
  final int totalMeasurements;
  final int daysActive;
  final int goalsAchieved;

  UserStats({
    required this.totalMeasurements,
    required this.daysActive,
    required this.goalsAchieved,
  });
}


// Hive adapter untuk model UserProfile
class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return UserProfile(
      name: fields[0] as String,
      age: fields[1] as int,
      height: (fields[2] as num).toDouble(),
      gender: fields[3] as String,
      activityLevel: fields[4] as String,
      memberSince: (fields[6] ?? fields[5]) as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.activityLevel)
      ..writeByte(5)
      ..write(obj.memberSince);
  }
}

