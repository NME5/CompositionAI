class UserProfile {
  final String name;
  int age;
  double height;
  String gender;
  String activityLevel;
  final String membershipType;
  final DateTime memberSince;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.membershipType,
    required this.memberSince,
  });

  // Copy with method for creating updated instances
  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    String? gender,
    String? activityLevel,
    String? membershipType,
    DateTime? memberSince,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      membershipType: membershipType ?? this.membershipType,
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

