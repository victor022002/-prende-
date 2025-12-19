import '/repositories/progress_repository.dart';
import '/models/achievement_model.dart';

class AchievementRepository {
  final ProgressRepository _progressRepo = ProgressRepository();

  Future<List<Achievement>> getAchievements(int studentId) async {
    final completed =
        await _progressRepo.getCompletedActivityIds(studentId);

    final completedSet = completed.toSet();

    bool hasAny = completedSet.isNotEmpty;
    bool firstSyllable =
        completedSet.any((id) => id >= 100 && id < 200);
    bool allSyllables =
        [100, 101, 110, 111, 120, 121].every(completedSet.contains);

    bool firstWriting =
        completedSet.any((id) => id >= 200 && id < 300);
    bool allWriting =
        [200, 201, 202, 203, 204].every(completedSet.contains);

    bool firstListening =
        completedSet.any((id) => id >= 300);
    bool allListening =
        [300, 301].every(completedSet.contains);

    return [
      Achievement(
        id: "G1",
        title: "Primer Paso",
        description: "Completaste tu primera actividad",
        unlocked: hasAny,
      ),
      Achievement(
        id: "A1",
        title: "Rompe Palabras",
        description: "Completaste tu primera palabra con sílabas",
        unlocked: firstSyllable,
      ),
      Achievement(
        id: "A2",
        title: "Maestro de Sílabas",
        description: "Completaste todas las sílabas",
        unlocked: allSyllables,
      ),
      Achievement(
        id: "B1",
        title: "Primer Trazo",
        description: "Escribiste tu primera vocal",
        unlocked: firstWriting,
      ),
      Achievement(
        id: "B2",
        title: "Vocales Felices",
        description: "Completaste todas las vocales",
        unlocked: allWriting,
      ),
      Achievement(
        id: "C1",
        title: "Buen Oído",
        description: "Completaste tu primera actividad de escucha",
        unlocked: firstListening,
      ),
      Achievement(
        id: "C2",
        title: "Escucha Experta",
        description: "Completaste todas las actividades de escucha",
        unlocked: allListening,
      ),
    ];
  }
}
