import 'package:equatable/equatable.dart';
import '../../../domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentBudget extends BudgetEvent {}

class CreateBudgetEvent extends BudgetEvent {
  final Budget budget;

  const CreateBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class UpdateBudgetEvent extends BudgetEvent {
  final Budget budget;

  const UpdateBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class UpdateBudgetSpendingEvent extends BudgetEvent {
  final String budgetId;
  final double amount;
  final String category;

  const UpdateBudgetSpendingEvent({
    required this.budgetId,
    required this.amount,
    required this.category,
  });

  @override
  List<Object?> get props => [budgetId, amount, category];
}
