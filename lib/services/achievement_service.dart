import '/repositories/achievement_repository.dart';
import '/models/achievement_model.dart';

class AchievementService {
  static final AchievementRepository _repo =
      AchievementRepository();

  static Set<String> _shown = {}; // evita repetir

  static Future<Achievement?> checkNew(
    int studentId,
  ) async {
    final achievements =
        await _repo.getAchievements(studentId);

    for (final a in achievements) {
      if (a.unlocked && !_shown.contains(a.id)) {
        _shown.add(a.id);
        return a; // 🔥 nuevo logro detectado
      }
    }
    return null;
  }
}
