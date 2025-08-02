import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../core/error/failures.dart';

class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<Either<Failure, String>> call(Expense expense) async {
    return await repository.addExpense(expense);
  }
}

class GetAllExpenses {
  final ExpenseRepository repository;

  GetAllExpenses(this.repository);

  Future<Either<Failure, List<Expense>>> call() async {
    return await repository.getAllExpenses();
  }
}

class GetExpensesByMonth {
  final ExpenseRepository repository;

  GetExpensesByMonth(this.repository);

  Future<Either<Failure, List<Expense>>> call(DateTime month) async {
    return await repository.getExpensesByMonth(month);
  }
}

class GetExpensesByCategory {
  final ExpenseRepository repository;

  GetExpensesByCategory(this.repository);

  Future<Either<Failure, List<Expense>>> call(String category) async {
    return await repository.getExpensesByCategory(category);
  }
}

class UpdateExpense {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  Future<Either<Failure, void>> call(Expense expense) async {
    return await repository.updateExpense(expense);
  }
}

class DeleteExpense {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteExpense(id);
  }
}

class GetTotalSpentByMonth {
  final ExpenseRepository repository;

  GetTotalSpentByMonth(this.repository);

  Future<Either<Failure, double>> call(DateTime month) async {
    return await repository.getTotalSpentByMonth(month);
  }
}

class GetCategoryTotals {
  final ExpenseRepository repository;

  GetCategoryTotals(this.repository);

  Future<Either<Failure, Map<String, double>>> call(DateTime month) async {
    return await repository.getCategoryTotals(month);
  }
}
