import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/budget_usecases.dart';
import '../../../domain/entities/budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetCurrentBudget getCurrentBudget;
  final CreateBudget createBudget;
  final UpdateBudget updateBudget;
  final UpdateBudgetSpending updateBudgetSpending;
  final GetYearlySavings getYearlySavings;
  final GetMonthlySavingsBreakdown getMonthlySavingsBreakdown;
  final GetBudgetsByYear getBudgetsByYear;

  BudgetBloc({
    required this.getCurrentBudget,
    required this.createBudget,
    required this.updateBudget,
    required this.updateBudgetSpending,
    required this.getYearlySavings,
    required this.getMonthlySavingsBreakdown,
    required this.getBudgetsByYear,
  }) : super(BudgetInitial()) {
    on<LoadCurrentBudget>(_onLoadCurrentBudget);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<UpdateBudgetSpendingEvent>(_onUpdateBudgetSpending);
    on<LoadYearlySavings>(_onLoadYearlySavings);
    on<LoadMonthlySavingsBreakdown>(_onLoadMonthlySavingsBreakdown);
    on<LoadYearlyBudgets>(_onLoadYearlyBudgets);
    on<LoadBudgetSummaryData>(_onLoadBudgetSummaryData);
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

  Future<void> _onLoadYearlySavings(LoadYearlySavings event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());

    final result = await getYearlySavings(event.year);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (yearlySavings) => emit(YearlySavingsLoaded(
        yearlySavings: yearlySavings,
        year: event.year,
      )),
    );
  }

  Future<void> _onLoadMonthlySavingsBreakdown(LoadMonthlySavingsBreakdown event, Emitter<BudgetState> emit) async {
    final result = await getMonthlySavingsBreakdown(event.year);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (monthlySavings) => emit(MonthlySavingsBreakdownLoaded(
        monthlySavings: monthlySavings,
        year: event.year,
      )),
    );
  }

  Future<void> _onLoadYearlyBudgets(LoadYearlyBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());

    final result = await getBudgetsByYear(event.year);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (yearlyBudgets) {
        // Create budget map for easy access by month
        final Map<int, Budget> budgetMap = {};
        for (final budget in yearlyBudgets) {
          budgetMap[budget.month.month] = budget;
        }

        emit(YearlyBudgetsLoaded(
          yearlyBudgets: yearlyBudgets,
          budgetMap: budgetMap,
          year: event.year,
        ));
      },
    );
  }

  Future<void> _onLoadBudgetSummaryData(LoadBudgetSummaryData event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());

    final yearlyBudgetsResult = await getBudgetsByYear(event.year);
    final yearlySavingsResult = await getYearlySavings(event.year);
    final monthlySavingsResult = await getMonthlySavingsBreakdown(event.year);

    if (yearlyBudgetsResult.isLeft() || yearlySavingsResult.isLeft() || monthlySavingsResult.isLeft()) {
      emit(const BudgetError('Failed to load budget summary data'));
      return;
    }

    final yearlyBudgets = yearlyBudgetsResult.getOrElse(() => []);
    final yearlySavings = yearlySavingsResult.getOrElse(() => 0.0);
    final monthlySavings = monthlySavingsResult.getOrElse(() => {});

    // Create budget map for easy access by month
    final Map<int, Budget> budgetMap = {};
    for (final budget in yearlyBudgets) {
      budgetMap[budget.month.month] = budget;
    }

    emit(BudgetSummaryLoaded(
      yearlySavings: yearlySavings,
      monthlySavings: monthlySavings,
      yearlyBudgets: yearlyBudgets,
      budgetMap: budgetMap,
      year: event.year,
    ));
  }
}
