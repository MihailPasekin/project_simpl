import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 🔹 Singleton (один объект на всё приложение)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 🔹 Получаем/создаём базу
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("app.db");
    return _database!;
  }

  // 🔹 Инициализация базы
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // 🔹 Создание таблиц
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  // 🔹 Добавить пользователя
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert("users", user);
  }

  // 🔹 Получить всех пользователей
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query("users");
  }

  // 🔹 Получить пользователя по email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // 🔹 Получить пользователя по email и паролю (для Login)
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
