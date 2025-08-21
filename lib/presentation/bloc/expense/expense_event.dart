import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllExpenses extends ExpenseEvent {}

class LoadExpensesByMonth extends ExpenseEvent {
  final DateTime month;

  const LoadExpensesByMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const AddExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String expenseId;

  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class LoadCategoryTotals extends ExpenseEvent {
  final DateTime month;

  const LoadCategoryTotals(this.month);

  @override
  List<Object?> get props => [month];
}

class LoadTotalSpent extends ExpenseEvent {
  final DateTime month;

  const LoadTotalSpent(this.month);

  @override
  List<Object?> get props => [month];
}

class LoadYearlyExpenses extends ExpenseEvent {
  final int year;

  const LoadYearlyExpenses(this.year);

  @override
  List<Object?> get props => [year];
}

class LoadMonthlyTotals extends ExpenseEvent {
  final int year;

  const LoadMonthlyTotals(this.year);

  @override
  List<Object?> get props => [year];
}

class LoadSummaryData extends ExpenseEvent {
  final int year;

  const LoadSummaryData(this.year);

  @override
  List<Object?> get props => [year];
}
