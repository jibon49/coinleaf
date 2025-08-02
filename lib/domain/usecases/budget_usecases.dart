import 'package:dartz/dartz.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';
import '../../core/error/failures.dart';

class GetCurrentBudget {
  final BudgetRepository repository;

  GetCurrentBudget(this.repository);

  Future<Either<Failure, Budget>> call() async {
    return await repository.getCurrentBudget();
  }
}

class CreateBudget {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  Future<Either<Failure, String>> call(Budget budget) async {
    return await repository.createBudget(budget);
  }
}

class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  Future<Either<Failure, void>> call(Budget budget) async {
    return await repository.updateBudget(budget);
  }
}

class UpdateBudgetSpending {
  final BudgetRepository repository;

  UpdateBudgetSpending(this.repository);

  Future<Either<Failure, void>> call(String budgetId, double amount, String category) async {
    return await repository.updateBudgetSpending(budgetId, amount, category);
  }
}
