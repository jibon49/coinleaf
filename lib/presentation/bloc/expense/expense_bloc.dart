import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/expense_usecases.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpense addExpense;
  final GetAllExpenses getAllExpenses;
  final GetExpensesByMonth getExpensesByMonth;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;
  final GetTotalSpentByMonth getTotalSpentByMonth;
  final GetCategoryTotals getCategoryTotals;
  final GetExpensesByYear getExpensesByYear;
  final GetYearlyExpenseTotal getYearlyExpenseTotal;
  final GetMonthlyExpenseTotals getMonthlyExpenseTotals;

  ExpenseBloc({
    required this.addExpense,
    required this.getAllExpenses,
    required this.getExpensesByMonth,
    required this.updateExpense,
    required this.deleteExpense,
    required this.getTotalSpentByMonth,
    required this.getCategoryTotals,
    required this.getExpensesByYear,
    required this.getYearlyExpenseTotal,
    required this.getMonthlyExpenseTotals,
  }) : super(ExpenseInitial()) {
    on<LoadAllExpenses>(_onLoadAllExpenses);
    on<LoadExpensesByMonth>(_onLoadExpensesByMonth);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<LoadCategoryTotals>(_onLoadCategoryTotals);
    on<LoadTotalSpent>(_onLoadTotalSpent);
    on<LoadYearlyExpenses>(_onLoadYearlyExpenses);
    on<LoadMonthlyTotals>(_onLoadMonthlyTotals);
    on<LoadSummaryData>(_onLoadSummaryData);
  }

  Future<void> _onLoadAllExpenses(LoadAllExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());

    final result = await getAllExpenses();
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onLoadExpensesByMonth(LoadExpensesByMonth event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());

    final expensesResult = await getExpensesByMonth(event.month);
    final totalResult = await getTotalSpentByMonth(event.month);
    final categoryResult = await getCategoryTotals(event.month);

    if (expensesResult.isLeft() || totalResult.isLeft() || categoryResult.isLeft()) {
      emit(const ExpenseError('Failed to load expense data'));
      return;
    }

    final expenses = expensesResult.getOrElse(() => []);
    final total = totalResult.getOrElse(() => 0.0);
    final categories = categoryResult.getOrElse(() => {});

    emit(ExpenseLoaded(
      expenses: expenses,
      totalSpent: total,
      categoryTotals: categories,
    ));
  }

  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    final result = await addExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (id) {
        emit(const ExpenseOperationSuccess('Expense added successfully'));
        // Refresh monthly totals for summary page last to preserve chart state
        final currentYear = DateTime.now().year;
        add(LoadMonthlyTotals(currentYear));
      },
    );
  }

  Future<void> _onUpdateExpense(UpdateExpenseEvent event, Emitter<ExpenseState> emit) async {
    final result = await updateExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) {
        emit(const ExpenseOperationSuccess('Expense updated successfully'));
        // Refresh monthly totals for summary page last to preserve chart state
        final currentYear = DateTime.now().year;
        add(LoadMonthlyTotals(currentYear));
      },
    );
  }

  Future<void> _onDeleteExpense(DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    final result = await deleteExpense(event.expenseId);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) {
        emit(const ExpenseOperationSuccess('Expense deleted successfully'));
        // Refresh monthly totals for summary page last to preserve chart state
        final currentYear = DateTime.now().year;
        add(LoadMonthlyTotals(currentYear));
      },
    );
  }

  Future<void> _onLoadCategoryTotals(LoadCategoryTotals event, Emitter<ExpenseState> emit) async {
    final result = await getCategoryTotals(event.month);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (categories) {
        if (state is ExpenseLoaded) {
          final currentState = state as ExpenseLoaded;
          emit(ExpenseLoaded(
            expenses: currentState.expenses,
            totalSpent: currentState.totalSpent,
            categoryTotals: categories,
          ));
        }
      },
    );
  }

  Future<void> _onLoadTotalSpent(LoadTotalSpent event, Emitter<ExpenseState> emit) async {
    final result = await getTotalSpentByMonth(event.month);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (total) {
        if (state is ExpenseLoaded) {
          final currentState = state as ExpenseLoaded;
          emit(ExpenseLoaded(
            expenses: currentState.expenses,
            totalSpent: total,
            categoryTotals: currentState.categoryTotals,
          ));
        }
      },
    );
  }

  Future<void> _onLoadYearlyExpenses(LoadYearlyExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());

    final expensesResult = await getExpensesByYear(event.year);
    final totalResult = await getYearlyExpenseTotal(event.year);

    if (expensesResult.isLeft() || totalResult.isLeft()) {
      emit(const ExpenseError('Failed to load yearly expense data'));
      return;
    }

    final expenses = expensesResult.getOrElse(() => []);
    final yearlyTotal = totalResult.getOrElse(() => 0.0);

    emit(YearlyExpenseLoaded(
      expenses: expenses,
      yearlyTotal: yearlyTotal,
      year: event.year,
    ));
  }

  Future<void> _onLoadMonthlyTotals(LoadMonthlyTotals event, Emitter<ExpenseState> emit) async {
    final result = await getMonthlyExpenseTotals(event.year);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (monthlyTotals) => emit(MonthlyTotalsLoaded(
        monthlyTotals: monthlyTotals,
        year: event.year,
      )),
    );
  }

  Future<void> _onLoadSummaryData(LoadSummaryData event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());

    final expensesResult = await getExpensesByYear(event.year);
    final totalResult = await getYearlyExpenseTotal(event.year);
    final monthlyTotalsResult = await getMonthlyExpenseTotals(event.year);

    if (expensesResult.isLeft() || totalResult.isLeft() || monthlyTotalsResult.isLeft()) {
      emit(const ExpenseError('Failed to load summary data'));
      return;
    }

    final expenses = expensesResult.getOrElse(() => []);
    final yearlyTotal = totalResult.getOrElse(() => 0.0);
    final monthlyTotals = monthlyTotalsResult.getOrElse(() => {});

    emit(YearlyExpenseWithMonthlyTotals(
      expenses: expenses,
      yearlyTotal: yearlyTotal,
      monthlyTotals: monthlyTotals,
      year: event.year,
    ));
  }
}
