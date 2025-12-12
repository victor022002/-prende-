enum ActivityType { reading, writing }

class Activity {
  final int? id;
  final ActivityType type;
  final String title;
  final String content;
  final String level;
  final bool isActive;

  Activity({
    this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.level,
    this.isActive = true,
  });
}
