class UserProfile {
  final String name;
  final int age;
  final double height;
  final double weight;
  final String activityLevel;
  final String membershipType;
  final DateTime memberSince;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.membershipType,
    required this.memberSince,
  });
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

