import 'package:project_simpl/models/account.dart';
import 'package:project_simpl/models/user.dart';
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
    CREATE TABLE users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  password TEXT NOT NULL,
  avatar TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);
  ''');

    await db.execute('''
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      name TEXT NOT NULL,
      balance REAL NOT NULL DEFAULT 0,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      accountId INTEGER NOT NULL,
      type TEXT NOT NULL,              
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

    final userWithDefaults = {
      ...user,
      "monthlyLimit": user["monthlyLimit"] ?? 0.0,
      "createdAt": user["createdAt"] ?? DateTime.now().toIso8601String(),
      "updatedAt": user["updatedAt"] ?? DateTime.now().toIso8601String(),
    };

    return await db.insert("users", userWithDefaults);
  }

  Future<int> registerUser(User user) async {
    final db = await database;
    final map = user.toMap();
    return await db.insert("users", map);
  }

  // Логин
  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) return User.fromMap(result.first);
    return null;
  }

  // Аккаунты
  Future<int> addAccount(User user, String name, double balance) async {
    final db = await database;
    return await db.insert('accounts', {
      'user_id': user.id,
      'account_name': name,
      'balance': balance,
    });
  }

  Future<List<Map<String, dynamic>>> getUserAccounts(User user) async {
    final db = await database;
    return await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
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

  // ================== ACCOUNTS ==================

  Future<int> updateAccount(Account account) async {
    final dbClient = await database;
    return await dbClient.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Account>> getAccounts(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      "accounts",
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "createdAt DESC",
    );
    return result.map((map) => Account.fromMap(map)).toList();
  }

  Future<int> deleteAccount(int accountId) async {
    final db = await instance.database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [accountId]);
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

  Future<List<Map<String, dynamic>>> getIncomes(int userId) async {
    final db = await database;
    return await db.query(
      "transactions",
      where: "userId = ? AND type = ?",
      whereArgs: [userId, "income"],
      orderBy: "date ASC",
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsByType(
    int userId,
    int? accountId,
    String type,
  ) async {
    final db = await database;
    String whereClause = "userId = ? AND type = ?";
    List<dynamic> whereArgs = [userId, type];

    if (accountId != null) {
      whereClause += " AND accountId = ?";
      whereArgs.add(accountId);
    }

    return await db.query(
      "transactions",
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: "date ASC",
    );
  }

  // В DatabaseHelper
  Future<List<Map<String, dynamic>>> getTransactionsForAccount(
    int userId,
    int accountId,
  ) async {
    final db = await database;

    // Пока в таблице нет accountId, можно фильтровать по note или category
    // если в note хранится info о счёте, иначе возвращаем все транзакции пользователя
    final result = await db.query(
      "transactions",
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "date ASC",
    );

    // Если хочешь, здесь можно оставить фильтр по note, если note содержит account.name
    return result;
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategoryAndPeriod(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;

    // Преобразуем даты в ISO строку
    String startIso = start.toIso8601String();
    String endIso = end.toIso8601String();

    final result = await db.rawQuery(
      '''
    SELECT category, SUM(amount) as total
    FROM transactions
    WHERE userId = ? AND type = 'expense' AND date BETWEEN ? AND ?
    GROUP BY category
  ''',
      [userId, startIso, endIso],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory(int userId) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT category, SUM(amount) as total
    FROM transactions
    WHERE userId = ? AND type = 'expense'
    GROUP BY category
  ''',
      [userId],
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

  Future<int> deleteUser(int userId) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
