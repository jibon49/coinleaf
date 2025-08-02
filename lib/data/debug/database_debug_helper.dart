import 'package:sqflite/sqflite.dart';
import '../datasources/database_helper.dart';

class DatabaseDebugHelper {
  static final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Print all tables and their data
  static Future<void> printAllData() async {
    try {
      final db = await _dbHelper.database;

      print('\n=== DATABASE DEBUG INFO ===');
      print('Database Path: ${db.path}');

      // Get all table names
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );

      print('\nTables found: ${tables.length}');

      for (final table in tables) {
        final tableName = table['name'] as String;
        await _printTableData(db, tableName);
      }

      print('\n=== END DEBUG INFO ===\n');
    } catch (e) {
      print('Error reading database: $e');
    }
  }

  // Print specific table data
  static Future<void> printTableData(String tableName) async {
    try {
      final db = await _dbHelper.database;
      await _printTableData(db, tableName);
    } catch (e) {
      print('Error reading table $tableName: $e');
    }
  }

  // Helper method to print table structure and data
  static Future<void> _printTableData(Database db, String tableName) async {
    try {
      print('\n--- TABLE: $tableName ---');

      // Get table schema
      final schema = await db.rawQuery("PRAGMA table_info($tableName)");
      print('Columns:');
      for (final column in schema) {
        print('  ${column['name']} (${column['type']})');
      }

      // Get row count
      final countResult = await db.rawQuery("SELECT COUNT(*) as count FROM $tableName");
      final rowCount = countResult.first['count'] as int;
      print('Total rows: $rowCount');

      // Get all data
      final data = await db.query(tableName);

      if (data.isEmpty) {
        print('No data in this table.');
      } else {
        print('\nData:');
        for (int i = 0; i < data.length; i++) {
          print('Row ${i + 1}:');
          data[i].forEach((key, value) {
            print('  $key: $value');
          });
          print('');
        }
      }

      print('--- END $tableName ---');
    } catch (e) {
      print('Error reading table $tableName: $e');
    }
  }

  // Print expenses for current month
  static Future<void> printCurrentMonthExpenses() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      print('\n--- CURRENT MONTH EXPENSES ---');
      print('Period: ${startOfMonth.toIso8601String()} to ${endOfMonth.toIso8601String()}');

      final expenses = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
        orderBy: 'date DESC',
      );

      if (expenses.isEmpty) {
        print('No expenses found for current month.');
      } else {
        double total = 0;
        for (final expense in expenses) {
          final amount = expense['amount'] as double;
          total += amount;
          print('${expense['date']}: ${expense['title']} - \$${amount.toStringAsFixed(2)} (${expense['category']})');
        }
        print('\nTotal for month: \$${total.toStringAsFixed(2)}');
      }

      print('--- END CURRENT MONTH EXPENSES ---');
    } catch (e) {
      print('Error reading current month expenses: $e');
    }
  }

  // Print budget information
  static Future<void> printBudgetInfo() async {
    try {
      final db = await _dbHelper.database;

      print('\n--- BUDGET INFO ---');

      final budgets = await db.query('budgets', orderBy: 'month DESC');

      if (budgets.isEmpty) {
        print('No budgets found.');
      } else {
        for (final budget in budgets) {
          print('Budget ID: ${budget['id']}');
          print('Month: ${budget['month']}');
          print('Monthly Limit: \$${budget['monthly_limit']}');
          print('Current Spent: \$${budget['current_spent']}');
          print('Active: ${budget['is_active'] == 1 ? 'Yes' : 'No'}');
          print('Created: ${budget['created_at']}');
          print('---');
        }
      }

      print('--- END BUDGET INFO ---');
    } catch (e) {
      print('Error reading budget info: $e');
    }
  }

  // Print category-wise spending summary
  static Future<void> printCategorySpendingSummary() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      print('\n--- CATEGORY SPENDING SUMMARY ---');

      final result = await db.rawQuery('''
        SELECT category, 
               COUNT(*) as expense_count,
               SUM(amount) as total_amount,
               AVG(amount) as avg_amount,
               MIN(amount) as min_amount,
               MAX(amount) as max_amount
        FROM expenses 
        WHERE date >= ? AND date <= ?
        GROUP BY category 
        ORDER BY total_amount DESC
      ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

      if (result.isEmpty) {
        print('No expenses found for current month.');
      } else {
        double grandTotal = 0;
        for (final row in result) {
          final total = row['total_amount'] as double;
          grandTotal += total;
          print('${row['category']}:');
          print('  Count: ${row['expense_count']}');
          print('  Total: \$${total.toStringAsFixed(2)}');
          print('  Average: \$${(row['avg_amount'] as double).toStringAsFixed(2)}');
          print('  Min: \$${(row['min_amount'] as double).toStringAsFixed(2)}');
          print('  Max: \$${(row['max_amount'] as double).toStringAsFixed(2)}');
          print('');
        }
        print('Grand Total: \$${grandTotal.toStringAsFixed(2)}');
      }

      print('--- END CATEGORY SUMMARY ---');
    } catch (e) {
      print('Error reading category summary: $e');
    }
  }
}
