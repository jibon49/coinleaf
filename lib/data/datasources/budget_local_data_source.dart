import '../models/budget_model.dart';
import 'database_helper.dart';
import '../../core/error/failures.dart';
import 'dart:convert';

abstract class BudgetLocalDataSource {
  Future<BudgetModel> getCurrentBudget();
  Future<BudgetModel?> getBudgetByMonth(DateTime month);
  Future<List<BudgetModel>> getAllBudgets();
  Future<List<BudgetModel>> getBudgetsByYear(int year);
  Future<String> createBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
  Future<void> updateBudgetSpending(String budgetId, double amount, String category);
  Future<double> getYearlySavings(int year);
  Future<Map<int, double>> getMonthlySavingsBreakdown(int year);
  Future<Map<int, BudgetModel>> getYearlyBudgetMap(int year);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final DatabaseHelper databaseHelper;

  BudgetLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<BudgetModel> getCurrentBudget() async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);

      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'month = ? AND is_active = 1',
        whereArgs: [currentMonth.toIso8601String()],
      );

      if (maps.isEmpty) {
        // Create a default budget for current month
        final currentSpent = await _calculateCurrentSpent(currentMonth);
        final categorySpent = await _calculateCategorySpent(currentMonth);

        final defaultBudget = BudgetModel(
          id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
          monthlyLimit: 1000.0,
          currentSpent: currentSpent,
          month: currentMonth,
          categoryLimits: const {},
          categorySpent: categorySpent,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await createBudget(defaultBudget);
        return defaultBudget;
      }

      // Get the budget data and recalculate spent amounts dynamically
      final budgetJson = Map<String, dynamic>.from(maps.first);
      final currentSpent = await _calculateCurrentSpent(currentMonth);
      final categorySpent = await _calculateCategorySpent(currentMonth);

      // Update the JSON with calculated values
      budgetJson['current_spent'] = currentSpent;
      budgetJson['category_spent'] = jsonEncode(categorySpent);

      return BudgetModel.fromJson(budgetJson);
    } catch (e) {
      throw DatabaseFailure('Failed to get current budget: $e');
    }
  }

  @override
  Future<BudgetModel?> getBudgetByMonth(DateTime month) async {
    try {
      final db = await databaseHelper.database;
      final targetMonth = DateTime(month.year, month.month, 1);

      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'month = ?',
        whereArgs: [targetMonth.toIso8601String()],
      );

      if (maps.isEmpty) {
        return null; // No budget found for the specified month
      }

      // Get the budget data and recalculate spent amounts dynamically
      final budgetJson = Map<String, dynamic>.from(maps.first);
      final currentSpent = await _calculateCurrentSpent(targetMonth);
      final categorySpent = await _calculateCategorySpent(targetMonth);

      // Update the JSON with calculated values
      budgetJson['current_spent'] = currentSpent;
      budgetJson['category_spent'] = jsonEncode(categorySpent);

      return BudgetModel.fromJson(budgetJson);
    } catch (e) {
      throw DatabaseFailure('Failed to get budget by month: $e');
    }
  }

  @override
  Future<List<BudgetModel>> getAllBudgets() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        orderBy: 'month DESC',
      );
      return maps.map((map) => BudgetModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get all budgets: $e');
    }
  }

  @override
  Future<List<BudgetModel>> getBudgetsByYear(int year) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'strftime("%Y", month) = ?',
        whereArgs: [year.toString()],
        orderBy: 'month DESC',
      );
      return maps.map((map) => BudgetModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get budgets by year: $e');
    }
  }

  @override
  Future<String> createBudget(BudgetModel budget) async {
    try {
      final db = await databaseHelper.database;
      await db.insert('budgets', budget.toJson());
      return budget.id;
    } catch (e) {
      throw DatabaseFailure('Failed to create budget: $e');
    }
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      final db = await databaseHelper.database;
      final updatedBudget = BudgetModel(
        id: budget.id,
        monthlyLimit: budget.monthlyLimit,
        currentSpent: budget.currentSpent,
        month: budget.month,
        categoryLimits: budget.categoryLimits,
        categorySpent: budget.categorySpent,
        isActive: budget.isActive,
        createdAt: budget.createdAt,
        updatedAt: DateTime.now(),
      );
      await db.update(
        'budgets',
        updatedBudget.toJson(),
        where: 'id = ?',
        whereArgs: [budget.id],
      );
    } catch (e) {
      throw DatabaseFailure('Failed to update budget: $e');
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'budgets',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseFailure('Failed to delete budget: $e');
    }
  }

  @override
  Future<void> updateBudgetSpending(String budgetId, double amount, String category) async {
    try {
      final db = await databaseHelper.database;

      // Get current budget
      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'id = ?',
        whereArgs: [budgetId],
      );

      if (maps.isEmpty) {
        throw DatabaseFailure('Budget not found');
      }

      final budget = BudgetModel.fromJson(maps.first);
      final updatedCategorySpent = Map<String, double>.from(budget.categorySpent);
      updatedCategorySpent[category] = (updatedCategorySpent[category] ?? 0.0) + amount;

      final updatedBudget = BudgetModel(
        id: budget.id,
        monthlyLimit: budget.monthlyLimit,
        currentSpent: budget.currentSpent + amount,
        month: budget.month,
        categoryLimits: budget.categoryLimits,
        categorySpent: updatedCategorySpent,
        isActive: budget.isActive,
        createdAt: budget.createdAt,
        updatedAt: DateTime.now(),
      );

      await updateBudget(updatedBudget);
    } catch (e) {
      throw DatabaseFailure('Failed to update budget spending: $e');
    }
  }

  @override
  Future<double> getYearlySavings(int year) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'strftime("%Y", month) = ?',
        whereArgs: [year.toString()],
      );

      double totalSavings = 0.0;
      for (var map in maps) {
        final budget = BudgetModel.fromJson(map);
        // Calculate savings as budget limit minus current spending
        final savings = budget.monthlyLimit - budget.currentSpent;
        totalSavings += savings;
      }

      return totalSavings;
    } catch (e) {
      throw DatabaseFailure('Failed to get yearly savings: $e');
    }
  }

  @override
  Future<Map<int, double>> getMonthlySavingsBreakdown(int year) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'strftime("%Y", month) = ?',
        whereArgs: [year.toString()],
        orderBy: 'month ASC',
      );

      final Map<int, double> monthlySavings = {};
      for (var map in maps) {
        final budget = BudgetModel.fromJson(map);
        final month = DateTime.parse(budget.month.toString()).month;
        monthlySavings[month] = budget.monthlyLimit - budget.currentSpent;
      }

      return monthlySavings;
    } catch (e) {
      throw DatabaseFailure('Failed to get monthly savings breakdown: $e');
    }
  }

  @override
  Future<Map<int, BudgetModel>> getYearlyBudgetMap(int year) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'strftime("%Y", month) = ?',
        whereArgs: [year.toString()],
        orderBy: 'month ASC',
      );

      final Map<int, BudgetModel> yearlyBudgetMap = {};
      for (var map in maps) {
        final budget = BudgetModel.fromJson(map);
        final month = DateTime.parse(budget.month.toString()).month;
        yearlyBudgetMap[month] = budget;
      }

      return yearlyBudgetMap;
    } catch (e) {
      throw DatabaseFailure('Failed to get yearly budget map: $e');
    }
  }

  // Helper method to calculate current spent amount from expenses
  Future<double> _calculateCurrentSpent(DateTime month) async {
    try {
      final db = await databaseHelper.database;
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
        [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      );

      final total = result.first['total'];
      return total != null ? (total as num).toDouble() : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Helper method to calculate category-wise spent amounts
  Future<Map<String, double>> _calculateCategorySpent(DateTime month) async {
    try {
      final db = await databaseHelper.database;
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final result = await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ? GROUP BY category',
        [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      );

      final Map<String, double> categorySpent = {};
      for (final row in result) {
        final category = row['category'] as String;
        final total = row['total'];
        categorySpent[category] = total != null ? (total as num).toDouble() : 0.0;
      }

      return categorySpent;
    } catch (e) {
      return {};
    }
  }
}
