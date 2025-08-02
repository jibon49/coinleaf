import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the database path
    final databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        has_vat INTEGER DEFAULT 0,
        vat_rate REAL DEFAULT 0.0,
        vat_amount REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        monthly_limit REAL NOT NULL,
        current_spent REAL DEFAULT 0.0,
        month TEXT NOT NULL,
        category_limits TEXT,
        category_spent TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE market_prices (
        id TEXT PRIMARY KEY,
        item_name TEXT NOT NULL,
        price REAL NOT NULL,
        unit TEXT NOT NULL,
        location TEXT,
        last_updated TEXT NOT NULL,
        source TEXT,
        previous_price REAL,
        price_change REAL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_expenses_category ON expenses(category)');
    await db.execute('CREATE INDEX idx_budgets_month ON budgets(month)');
    await db.execute('CREATE INDEX idx_market_prices_item ON market_prices(item_name)');

    // Insert default market prices
    await _insertDefaultMarketPrices(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add migration logic for future versions
    }
  }

  Future<void> _insertDefaultMarketPrices(Database db) async {
    final defaultPrices = [
      {
        'id': 'rice_001',
        'item_name': 'Rice',
        'price': 2.50,
        'unit': 'kg',
        'location': 'Local Market',
        'last_updated': DateTime.now().toIso8601String(),
        'source': 'Local',
        'previous_price': 2.40,
        'price_change': 0.10,
      },
      {
        'id': 'oil_001',
        'item_name': 'Cooking Oil',
        'price': 4.20,
        'unit': 'liter',
        'location': 'Local Market',
        'last_updated': DateTime.now().toIso8601String(),
        'source': 'Local',
        'previous_price': 4.00,
        'price_change': 0.20,
      },
      {
        'id': 'vegetables_001',
        'item_name': 'Vegetables',
        'price': 3.50,
        'unit': 'kg',
        'location': 'Local Market',
        'last_updated': DateTime.now().toIso8601String(),
        'source': 'Local',
        'previous_price': 3.30,
        'price_change': 0.20,
      },
      {
        'id': 'milk_001',
        'item_name': 'Milk',
        'price': 1.80,
        'unit': 'liter',
        'location': 'Local Market',
        'last_updated': DateTime.now().toIso8601String(),
        'source': 'Local',
        'previous_price': 1.75,
        'price_change': 0.05,
      },
      {
        'id': 'eggs_001',
        'item_name': 'Eggs',
        'price': 3.00,
        'unit': 'dozen',
        'location': 'Local Market',
        'last_updated': DateTime.now().toIso8601String(),
        'source': 'Local',
        'previous_price': 2.90,
        'price_change': 0.10,
      },
    ];

    for (final price in defaultPrices) {
      await db.insert('market_prices', price);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
