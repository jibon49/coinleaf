import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalSpent;
  final Map<String, double> categoryTotals;

  const ExpenseLoaded({
    required this.expenses,
    this.totalSpent = 0.0,
    this.categoryTotals = const {},
  });

  @override
  List<Object?> get props => [expenses, totalSpent, categoryTotals];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;

  const ExpenseOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

class YearlyExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double yearlyTotal;
  final int year;

  const YearlyExpenseLoaded({
    required this.expenses,
    required this.yearlyTotal,
    required this.year,
  });

  @override
  List<Object?> get props => [expenses, yearlyTotal, year];
}

class MonthlyTotalsLoaded extends ExpenseState {
  final Map<int, double> monthlyTotals;
  final int year;

  const MonthlyTotalsLoaded({
    required this.monthlyTotals,
    required this.year,
  });

  @override
  List<Object?> get props => [monthlyTotals, year];
}

class YearlyExpenseWithMonthlyTotals extends ExpenseState {
  final List<Expense> expenses;
  final double yearlyTotal;
  final Map<int, double> monthlyTotals;
  final int year;

  const YearlyExpenseWithMonthlyTotals({
    required this.expenses,
    required this.yearlyTotal,
    required this.monthlyTotals,
    required this.year,
  });

  @override
  List<Object?> get props => [expenses, yearlyTotal, monthlyTotals, year];
}
