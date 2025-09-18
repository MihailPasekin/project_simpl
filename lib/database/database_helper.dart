import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 🔹 Singleton
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
      password TEXT NOT NULL,
      monthlyLimit REAL NOT NULL,
      avatar TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      type TEXT NOT NULL,              -- "income" или "expense"
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      note TEXT,
      date TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
    )
  ''');
  }

  // ================== USERS ==================

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;

    // 👇 Добавляем дефолтные значения, если их нет
    final userWithDefaults = {
      ...user,
      "monthlyLimit": user["monthlyLimit"] ?? 0.0,
      "createdAt": user["createdAt"] ?? DateTime.now().toIso8601String(),
      "updatedAt": user["updatedAt"] ?? DateTime.now().toIso8601String(),
    };

    return await db.insert("users", userWithDefaults);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    return await db.query("users");
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ================== TRANSACTIONS ==================

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await instance.database;
    return await db.insert("transactions", transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    final db = await instance.database;
    return await db.query(
      "transactions",
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "date DESC",
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete("transactions", where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateTransaction(
    int id,
    Map<String, dynamic> transaction,
  ) async {
    final db = await instance.database;
    return await db.update(
      "transactions",
      transaction,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
