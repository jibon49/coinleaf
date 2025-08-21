import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../../core/error/failures.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, String>> addExpense(Expense expense);
  Future<Either<Failure, List<Expense>>> getAllExpenses();
  Future<Either<Failure, List<Expense>>> getExpensesByMonth(DateTime month);
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String category);
  Future<Either<Failure, List<Expense>>> getExpensesByYear(int year);
  Future<Either<Failure, void>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, double>> getTotalSpentByMonth(DateTime month);
  Future<Either<Failure, double>> getYearlyExpenseTotal(int year);
  Future<Either<Failure, Map<String, double>>> getCategoryTotals(DateTime month);
  Future<Either<Failure, Map<int, double>>> getMonthlyExpenseTotals(int year);
}
