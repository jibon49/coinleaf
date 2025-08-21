import 'package:equatable/equatable.dart';
import '../../../domain/entities/budget.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final Budget budget;

  const BudgetLoaded(this.budget);

  @override
  List<Object?> get props => [budget];
}

class BudgetOperationSuccess extends BudgetState {
  final String message;

  const BudgetOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

class YearlySavingsLoaded extends BudgetState {
  final double yearlySavings;
  final int year;

  const YearlySavingsLoaded({
    required this.yearlySavings,
    required this.year,
  });

  @override
  List<Object?> get props => [yearlySavings, year];
}

class MonthlySavingsBreakdownLoaded extends BudgetState {
  final Map<int, double> monthlySavings;
  final int year;

  const MonthlySavingsBreakdownLoaded({
    required this.monthlySavings,
    required this.year,
  });

  @override
  List<Object?> get props => [monthlySavings, year];
}

class YearlyBudgetsLoaded extends BudgetState {
  final List<Budget> yearlyBudgets;
  final Map<int, Budget> budgetMap;
  final int year;

  const YearlyBudgetsLoaded({
    required this.yearlyBudgets,
    required this.budgetMap,
    required this.year,
  });

  @override
  List<Object?> get props => [yearlyBudgets, budgetMap, year];
}

class BudgetSummaryLoaded extends BudgetState {
  final double yearlySavings;
  final Map<int, double> monthlySavings;
  final List<Budget> yearlyBudgets;
  final Map<int, Budget> budgetMap;
  final int year;

  const BudgetSummaryLoaded({
    required this.yearlySavings,
    required this.monthlySavings,
    required this.yearlyBudgets,
    required this.budgetMap,
    required this.year,
  });

  @override
  List<Object?> get props => [yearlySavings, monthlySavings, yearlyBudgets, budgetMap, year];
}
