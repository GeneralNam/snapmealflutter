// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meals.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        type TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        description TEXT,
        nutrition TEXT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // 식사 기록 저장
  Future<int> saveMeal({
    required String date,
    required String time,
    required String type,
    required String imagePath,
    String? description,
    required String nutrition,
  }) async {
    final db = await instance.database;

    // 이미지 파일을 앱의 로컬 저장소로 복사
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String localImagePath =
        join(documentsDirectory.path, 'meal_images', fileName);

    // 이미지 저장 디렉토리 생성
    await Directory(join(documentsDirectory.path, 'meal_images'))
        .create(recursive: true);

    // 이미지 파일 복사
    await File(imagePath).copy(localImagePath);

    final data = {
      'date': date,
      'time': time,
      'type': type,
      'imagePath': localImagePath,
      'description': description,
      'nutrition': nutrition,
    };

    return await db.insert('meals', data);
  }

  // 모든 식사 기록 조회
  Future<List<Map<String, dynamic>>> getAllMeals() async {
    final db = await instance.database;
    return await db.query('meals', orderBy: 'createdAt DESC');
  }

  // 특정 날짜의 식사 기록 조회
  Future<List<Map<String, dynamic>>> getMealsByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'meals',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time DESC',
    );
  }

  // DB 삭제 메서드 추가
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meals.db');

    // DB 파일 삭제
    await databaseFactory.deleteDatabase(path);

    // 이미지 파일들도 삭제
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final imageDir = Directory(join(documentsDirectory.path, 'meal_images'));
    if (await imageDir.exists()) {
      await imageDir.delete(recursive: true);
    }

    // database 인스턴스 초기화
    _database = null;
  }
}
