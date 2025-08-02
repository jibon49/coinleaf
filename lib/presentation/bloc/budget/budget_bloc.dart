import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/budget_usecases.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetCurrentBudget getCurrentBudget;
  final CreateBudget createBudget;
  final UpdateBudget updateBudget;
  final UpdateBudgetSpending updateBudgetSpending;

  BudgetBloc({
    required this.getCurrentBudget,
    required this.createBudget,
    required this.updateBudget,
    required this.updateBudgetSpending,
  }) : super(BudgetInitial()) {
    on<LoadCurrentBudget>(_onLoadCurrentBudget);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<UpdateBudgetSpendingEvent>(_onUpdateBudgetSpending);
  }

  Future<void> _onLoadCurrentBudget(LoadCurrentBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());

    final result = await getCurrentBudget();
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budget) => emit(BudgetLoaded(budget)),
    );
  }

  Future<void> _onCreateBudget(CreateBudgetEvent event, Emitter<BudgetState> emit) async {
    final result = await createBudget(event.budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (id) {
        emit(const BudgetOperationSuccess('Budget created successfully'));
        add(LoadCurrentBudget());
      },
    );
  }

  Future<void> _onUpdateBudget(UpdateBudgetEvent event, Emitter<BudgetState> emit) async {
    final result = await updateBudget(event.budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        emit(const BudgetOperationSuccess('Budget updated successfully'));
        add(LoadCurrentBudget());
      },
    );
  }

  Future<void> _onUpdateBudgetSpending(UpdateBudgetSpendingEvent event, Emitter<BudgetState> emit) async {
    final result = await updateBudgetSpending(event.budgetId, event.amount, event.category);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        add(LoadCurrentBudget());
      },
    );
  }
}
