import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lecture.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'lectures';

  // الحصول على قاعدة البيانات
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // تهيئة قاعدة البيانات
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'jameti.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // إنشاء جداول قاعدة البيانات
  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        doctor_name TEXT,
        start_time TEXT NOT NULL,
        location TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // إضافة محاضرة جديدة
  static Future<int> insertLecture(Lecture lecture) async {
    final db = await database;
    return await db.insert(_tableName, lecture.toMap());
  }

  // الحصول على جميع المحاضرات
  static Future<List<Lecture>> getAllLectures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'day_of_week ASC, start_time ASC',
    );

    return List.generate(maps.length, (i) {
      return Lecture.fromMap(maps[i]);
    });
  }

  // الحصول على محاضرات يوم معين
  static Future<List<Lecture>> getLecturesByDay(int dayOfWeek) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'day_of_week = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'start_time ASC',
    );

    return List.generate(maps.length, (i) {
      return Lecture.fromMap(maps[i]);
    });
  }

  // البحث في المحاضرات
  static Future<List<Lecture>> searchLectures(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR doctor_name LIKE ? OR location LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'day_of_week ASC, start_time ASC',
    );

    return List.generate(maps.length, (i) {
      return Lecture.fromMap(maps[i]);
    });
  }

  // تحديث محاضرة
  static Future<int> updateLecture(Lecture lecture) async {
    final db = await database;
    return await db.update(
      _tableName,
      lecture.toMap(),
      where: 'id = ?',
      whereArgs: [lecture.id],
    );
  }

  // حذف محاضرة
  static Future<int> deleteLecture(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // حذف جميع المحاضرات
  static Future<int> deleteAllLectures() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  // الحصول على عدد المحاضرات
  static Future<int> getLectureCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // إغلاق قاعدة البيانات
  static Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

