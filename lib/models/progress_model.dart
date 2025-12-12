enum ProgressStatus { notStarted, inProgress, completed }

class Progress {
  final int? id;
  final int studentId;
  final int activityId;
  final ProgressStatus status;
  final int attempts;
  final double? score;
  final DateTime lastUpdated;
  final bool pendingSync;

  Progress({
    this.id,
    required this.studentId,
    required this.activityId,
    this.status = ProgressStatus.notStarted,
    this.attempts = 0,
    this.score,
    DateTime? lastUpdated,
    this.pendingSync = true,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
}
