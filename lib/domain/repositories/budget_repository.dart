import 'package:dartz/dartz.dart';
import '../entities/budget.dart';
import '../../core/error/failures.dart';

abstract class BudgetRepository {
  Future<Either<Failure, Budget>> getCurrentBudget();
  Future<Either<Failure, Budget>> getBudgetByMonth(DateTime month);
  Future<Either<Failure, List<Budget>>> getAllBudgets();
  Future<Either<Failure, String>> createBudget(Budget budget);
  Future<Either<Failure, void>> updateBudget(Budget budget);
  Future<Either<Failure, void>> deleteBudget(String id);
  Future<Either<Failure, void>> updateBudgetSpending(String budgetId, double amount, String category);
}
