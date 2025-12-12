import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'tables.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'aprende_plus.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute(createStudentsTable);
        await db.execute(createActivitiesTable);
        await db.execute(createProgressTable);
      },
    );
  }
}
