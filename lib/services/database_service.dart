import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aprende.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        progress INTEGER NOT NULL,
        completedReading INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        foto_url TEXT,
        updated_at INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_profile (
          uid TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          foto_url TEXT,
          updated_at INTEGER
        )
      ''');
    }
  }

  Future<int> addStudent(Student student) async {
    final db = await instance.database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getStudents() async {
    final db = await instance.database;
    final result = await db.query('students');
    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> updateProgress(int id, int progress) async {
    final db = await instance.database;
    return await db.update(
      'students',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateStudentField(int id, String field, dynamic value) async {
    final db = await instance.database;
    return await db.update(
      'students',
      {field: value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> upsertUserProfile({
    required String uid,
    required String email,
    String? fotoUrl,
  }) async {
    final db = await instance.database;

    await db.insert(
      'user_profile',
      {
        'uid': uid,
        'email': email,
        'foto_url': fotoUrl,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final db = await instance.database;
    final rows = await db.query(
      'user_profile',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }
}
