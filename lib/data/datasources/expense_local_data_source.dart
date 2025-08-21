import '../models/expense_model.dart';
import 'database_helper.dart';
import '../../core/error/failures.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<List<ExpenseModel>> getExpensesByMonth(DateTime month);
  Future<List<ExpenseModel>> getExpensesByCategory(String category);
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<List<ExpenseModel>> getExpensesByYear(int year);
  Future<ExpenseModel> getExpenseById(String id);
  Future<String> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<double> getTotalSpentByMonth(DateTime month);
  Future<double> getYearlyExpenseTotal(int year);
  Future<Map<String, double>> getCategoryTotals(DateTime month);
  Future<Map<int, double>> getMonthlyExpenseTotals(int year);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final DatabaseHelper databaseHelper;

  ExpenseLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        orderBy: 'date DESC',
      );
      return maps.map((map) => ExpenseModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get all expenses: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByMonth(DateTime month) async {
    try {
      final db = await databaseHelper.database;
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [
          startOfMonth.toIso8601String(),
          endOfMonth.toIso8601String(),
        ],
        orderBy: 'date DESC',
      );
      return maps.map((map) => ExpenseModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get expenses by month: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'date DESC',
      );
      return maps.map((map) => ExpenseModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get expenses by category: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      return maps.map((map) => ExpenseModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get expenses by date range: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByYear(int year) async {
    try {
      final db = await databaseHelper.database;
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year, 12, 31);

      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [
          startOfYear.toIso8601String(),
          endOfYear.toIso8601String(),
        ],
        orderBy: 'date DESC',
      );
      return maps.map((map) => ExpenseModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get expenses by year: $e');
    }
  }

  @override
  Future<ExpenseModel> getExpenseById(String id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        throw DatabaseFailure('Expense not found');
      }

      return ExpenseModel.fromJson(maps.first);
    } catch (e) {
      throw DatabaseFailure('Failed to get expense by id: $e');
    }
  }

  @override
  Future<String> addExpense(ExpenseModel expense) async {
    try {
      final db = await databaseHelper.database;
      await db.insert('expenses', expense.toJson());
      return expense.id;
    } catch (e) {
      throw DatabaseFailure('Failed to add expense: $e');
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final db = await databaseHelper.database;
      final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
      await db.update(
        'expenses',
        ExpenseModel.fromEntity(updatedExpense).toJson(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } catch (e) {
      throw DatabaseFailure('Failed to update expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseFailure('Failed to delete expense: $e');
    }
  }

  @override
  Future<double> getTotalSpentByMonth(DateTime month) async {
    try {
      final db = await databaseHelper.database;
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount + vat_amount) as total FROM expenses WHERE date >= ? AND date <= ?',
        [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseFailure('Failed to get total spent by month: $e');
    }
  }

  @override
  Future<double> getYearlyExpenseTotal(int year) async {
    try {
      final db = await databaseHelper.database;
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year, 12, 31);

      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount + vat_amount) as total FROM expenses WHERE date >= ? AND date <= ?',
        [startOfYear.toIso8601String(), endOfYear.toIso8601String()],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseFailure('Failed to get yearly expense total: $e');
    }
  }

  @override
  Future<Map<String, double>> getCategoryTotals(DateTime month) async {
    try {
      final db = await databaseHelper.database;
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT category, SUM(amount + vat_amount) as total FROM expenses WHERE date >= ? AND date <= ? GROUP BY category',
        [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      );

      final Map<String, double> categoryTotals = {};
      for (final row in result) {
        categoryTotals[row['category'] as String] = (row['total'] as num).toDouble();
      }

      return categoryTotals;
    } catch (e) {
      throw DatabaseFailure('Failed to get category totals: $e');
    }
  }

  @override
  Future<Map<int, double>> getMonthlyExpenseTotals(int year) async {
    try {
      final db = await databaseHelper.database;

      // Use proper date format for SQLite comparison
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''SELECT 
           CAST(strftime('%m', date) AS INTEGER) as month, 
           SUM(amount + COALESCE(vat_amount, 0)) as total 
           FROM expenses 
           WHERE strftime('%Y', date) = ? 
           GROUP BY strftime('%m', date) 
           ORDER BY month''',
        [year.toString()],
      );

      final Map<int, double> monthlyTotals = {};
      for (final row in result) {
        final month = row['month'] as int;
        final total = (row['total'] as num?)?.toDouble() ?? 0.0;
        monthlyTotals[month] = total;
      }

      return monthlyTotals;
    } catch (e) {
      throw DatabaseFailure('Failed to get monthly expense totals: $e');
    }
  }
}
