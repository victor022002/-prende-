const String createStudentsTable = '''
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  level TEXT NOT NULL,
  created_at TEXT NOT NULL
);
''';

const String createActivitiesTable = '''
CREATE TABLE activities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  level TEXT NOT NULL,
  is_active INTEGER NOT NULL
);
''';

const String createProgressTable = '''
CREATE TABLE progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  activity_id INTEGER NOT NULL,
  status TEXT NOT NULL,
  attempts INTEGER NOT NULL,
  score REAL,
  last_updated TEXT NOT NULL,
  pending_sync INTEGER NOT NULL,
  UNIQUE(student_id, activity_id)
);
''';
