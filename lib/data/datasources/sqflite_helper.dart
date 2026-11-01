import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart'; // 🔧

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sku TEXT NOT NULL,
        price REAL NOT NULL,
        costPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        image TEXT NOT NULL
      )
    ''');
    await _createTransactionsTable(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTransactionsTable(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN timestamp INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN quantityChange INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN productId INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityName TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        isIncome INTEGER NOT NULL,
        status TEXT NOT NULL,
         timestamp INTEGER NOT NULL DEFAULT 0,
      quantityChange INTEGER NOT NULL DEFAULT 0,
      productId INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await instance.database;
    final data = product.toMap()..remove('id');
    return await db.insert('products', data);
  }

  Future<List<ProductModel>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'id DESC');
    return result.map((json) => ProductModel.fromMap(json)).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await instance.database;
    final data = tx.toMap()..remove('id');
    return await db.insert('transactions', data);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'id DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
