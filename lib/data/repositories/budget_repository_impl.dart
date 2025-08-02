import 'package:dartz/dartz.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/budget_local_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Budget>> getCurrentBudget() async {
    try {
      final budget = await localDataSource.getCurrentBudget();
      return Right(budget);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Budget>> getBudgetByMonth(DateTime month) async {
    try {
      final budget = await localDataSource.getBudgetByMonth(month);
      return Right(budget);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Budget>>> getAllBudgets() async {
    try {
      final budgets = await localDataSource.getAllBudgets();
      return Right(budgets);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createBudget(Budget budget) async {
    try {
      final budgetModel = BudgetModel.fromEntity(budget);
      final id = await localDataSource.createBudget(budgetModel);
      return Right(id);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudget(Budget budget) async {
    try {
      final budgetModel = BudgetModel.fromEntity(budget);
      await localDataSource.updateBudget(budgetModel);
      return const Right(null);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await localDataSource.deleteBudget(id);
      return const Right(null);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudgetSpending(String budgetId, double amount, String category) async {
    try {
      await localDataSource.updateBudgetSpending(budgetId, amount, category);
      return const Right(null);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }
}
