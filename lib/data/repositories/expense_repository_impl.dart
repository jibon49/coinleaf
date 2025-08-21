import 'package:dartz/dartz.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final expenses = await localDataSource.getAllExpenses();
      return Right(expenses);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByMonth(DateTime month) async {
    try {
      final expenses = await localDataSource.getExpensesByMonth(month);
      return Right(expenses);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String category) async {
    try {
      final expenses = await localDataSource.getExpensesByCategory(category);
      return Right(expenses);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final expenses = await localDataSource.getExpensesByDateRange(start, end);
      return Right(expenses);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, Expense>> getExpenseById(String id) async {
    try {
      final expense = await localDataSource.getExpenseById(id);
      return Right(expense);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final id = await localDataSource.addExpense(expenseModel);
      return Right(id);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await localDataSource.updateExpense(expenseModel);
      return const Right(null);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
      return const Right(null);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalSpentByMonth(DateTime month) async {
    try {
      final total = await localDataSource.getTotalSpentByMonth(month);
      return Right(total);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getCategoryTotals(DateTime month) async {
    try {
      final totals = await localDataSource.getCategoryTotals(month);
      return Right(totals);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByYear(int year) async {
    try {
      final expenses = await localDataSource.getExpensesByYear(year);
      return Right(expenses);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getYearlyExpenseTotal(int year) async {
    try {
      final total = await localDataSource.getYearlyExpenseTotal(year);
      return Right(total);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<int, double>>> getMonthlyExpenseTotals(int year) async {
    try {
      final monthleTotals = await localDataSource.getMonthlyExpenseTotals(year);
      return Right(monthleTotals);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }
}
