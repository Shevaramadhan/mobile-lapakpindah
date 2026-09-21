import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Singleton helper SQLite database LapakPindah.
class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'lapak_pindah.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel users (auth)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        identifier TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabel lokasi (Modul 1)
    await db.execute('''
      CREATE TABLE location_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_name TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        rent_cost REAL DEFAULT 0,
        open_time TEXT,
        close_time TEXT,
        date_recorded TEXT NOT NULL
      )
    ''');

    // Tabel pengeluaran (Modul 2)
    await db.execute('''
      CREATE TABLE expense_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_id INTEGER,
        expense_name TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        receipt_photo_path TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (location_id) REFERENCES location_logs (id)
      )
    ''');

    // Tabel produk & resep (Modul 3)
    await db.execute('''
      CREATE TABLE product_recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        selling_price REAL NOT NULL,
        recipe_cost REAL DEFAULT 0,
        initial_stock INTEGER DEFAULT 0,
        current_stock INTEGER DEFAULT 0,
        ingredients_json TEXT
      )
    ''');

    // Tabel transaksi penjualan (Modul 3)
    await db.execute('''
      CREATE TABLE sales_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_id INTEGER,
        product_id INTEGER,
        qty INTEGER NOT NULL,
        total_price REAL NOT NULL,
        timestamp TEXT NOT NULL,
        is_void INTEGER DEFAULT 0,
        FOREIGN KEY (location_id) REFERENCES location_logs (id),
        FOREIGN KEY (product_id) REFERENCES product_recipes (id)
      )
    ''');

    // Seed demo user
    await db.insert('users', {
      'name': 'Kak Rina',
      'identifier': '0812345678',
      'password': '123456',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ── Auth Methods ──

  /// Insert user baru.
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  /// Cari user berdasarkan identifier (WA/email).
  Future<Map<String, dynamic>?> getUserByIdentifier(String identifier) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'identifier = ?',
      whereArgs: [identifier],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Validasi login.
  Future<Map<String, dynamic>?> validateLogin(
    String identifier,
    String password,
  ) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'identifier = ? AND password = ?',
      whereArgs: [identifier, password],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ── Dashboard Aggregation ──

  /// Total penjualan hari ini (non-void).
  Future<double> getTodayRevenue() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(total_price), 0) as total FROM sales_transactions WHERE is_void = 0 AND timestamp LIKE '$today%'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  /// Total pengeluaran hari ini.
  Future<double> getTodayExpense() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM expense_records WHERE timestamp LIKE '$today%'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}
