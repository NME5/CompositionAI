class Insight {
  final String title;
  final String description;
  final String type;

  Insight({
    required this.title,
    required this.description,
    required this.type,
  });
}

class Recommendation {
  final String emoji;
  final String title;
  final String description;
  final String priority;
  final int priorityColor;

  Recommendation({
    required this.emoji,
    required this.title,
    required this.description,
    required this.priority,
    required this.priorityColor,
  });
}

class HealthScore {
  final int overall;
  final int bodyComp;
  final int fitness;
  final int wellness;

  HealthScore({
    required this.overall,
    required this.bodyComp,
    required this.fitness,
    required this.wellness,
  });
}

