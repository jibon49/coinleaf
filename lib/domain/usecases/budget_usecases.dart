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

class GetBudgetsByYear {
  final BudgetRepository repository;

  GetBudgetsByYear(this.repository);

  Future<Either<Failure, List<Budget>>> call(int year) async {
    return await repository.getBudgetsByYear(year);
  }
}

class GetBudgetByMonth {
  final BudgetRepository repository;

  GetBudgetByMonth(this.repository);

  Future<Either<Failure, Budget?>> call(DateTime month) async {
    return await repository.getBudgetByMonth(month);
  }
}

class GetYearlySavings {
  final BudgetRepository repository;

  GetYearlySavings(this.repository);

  Future<Either<Failure, double>> call(int year) async {
    return await repository.getYearlySavings(year);
  }
}

class GetMonthlySavingsBreakdown {
  final BudgetRepository repository;

  GetMonthlySavingsBreakdown(this.repository);

  Future<Either<Failure, Map<int, double>>> call(int year) async {
    return await repository.getMonthlySavingsBreakdown(year);
  }
}
