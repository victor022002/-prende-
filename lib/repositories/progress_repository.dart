import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/progress_model.dart';

class ProgressRepository {
  // ======================
  // WRITE
  // ======================
  Future<void> saveOrUpdate(Progress progress) async {
    final Database db = await AppDatabase.instance;

    await db.insert(
      'progress',
      {
        'student_id': progress.studentId,
        'activity_id': progress.activityId,
        'status': progress.status.name,
        'attempts': progress.attempts,
        'score': progress.score,
        'last_updated': progress.lastUpdated.toIso8601String(),
        'pending_sync': progress.pendingSync ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ======================
  // READ
  // ======================

  /// Devuelve el progreso de UNA actividad para un alumno
  /// (o null si nunca la ha iniciado)
  Future<Progress?> getProgressForActivity({
    required int studentId,
    required int activityId,
  }) async {
    final Database db = await AppDatabase.instance;

    final List<Map<String, dynamic>> rows = await db.query(
      'progress',
      where: 'student_id = ? AND activity_id = ?',
      whereArgs: [studentId, activityId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  /// Indica si una actividad está COMPLETADA por el alumno
  Future<bool> isActivityCompleted({
    required int studentId,
    required int activityId,
  }) async {
    final Database db = await AppDatabase.instance;

    final List<Map<String, dynamic>> rows = await db.query(
      'progress',
      columns: ['id'],
      where:
          'student_id = ? AND activity_id = ? AND status = ?',
      whereArgs: [
        studentId,
        activityId,
        ProgressStatus.completed.name,
      ],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  /// Devuelve TODOS los activityId completados por el alumno
  Future<List<int>> getCompletedActivityIds(int studentId) async {
    final Database db = await AppDatabase.instance;

    final List<Map<String, dynamic>> rows = await db.query(
      'progress',
      columns: ['activity_id'],
      where:
          'student_id = ? AND status = ?',
      whereArgs: [
        studentId,
        ProgressStatus.completed.name,
      ],
    );

    return rows
        .map((r) => r['activity_id'] as int)
        .toList();
  }

  /// Cuenta cuántas actividades ha completado el alumno
  Future<int> countCompletedActivities(int studentId) async {
    final Database db = await AppDatabase.instance;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM progress
      WHERE student_id = ?
        AND status = ?
      ''',
      [
        studentId,
        ProgressStatus.completed.name,
      ],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ======================
  // HELPERS
  // ======================
  Progress _fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      activityId: map['activity_id'] as int,
      status: ProgressStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      attempts: map['attempts'] as int,
      score: map['score'] as double?,
      lastUpdated: DateTime.parse(map['last_updated']),
      pendingSync: (map['pending_sync'] as int) == 1,
    );
  }
}

