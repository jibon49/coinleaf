import 'package:get_it/get_it.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/expense_local_data_source.dart';
import 'data/datasources/budget_local_data_source.dart';
import 'data/datasources/market_price_local_data_source.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'data/repositories/budget_repository_impl.dart';
import 'data/repositories/market_price_repository_impl.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/budget_repository.dart';
import 'domain/repositories/market_price_repository.dart';
import 'domain/usecases/expense_usecases.dart';
import 'domain/usecases/budget_usecases.dart';
import 'domain/usecases/market_price_usecases.dart';
import 'presentation/bloc/expense/expense_bloc.dart';
import 'presentation/bloc/budget/budget_bloc.dart';
import 'presentation/bloc/market_price/market_price_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core - Initialize database helper first
  final databaseHelper = DatabaseHelper.instance;
  getIt.registerSingleton<DatabaseHelper>(databaseHelper);

  // Initialize the database to ensure it's ready
  await databaseHelper.database;

  // Data Sources
  getIt.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(databaseHelper: getIt()),
  );
  getIt.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSourceImpl(databaseHelper: getIt()),
  );
  getIt.registerLazySingleton<MarketPriceLocalDataSource>(
    () => MarketPriceLocalDataSourceImpl(databaseHelper: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<MarketPriceRepository>(
    () => MarketPriceRepositoryImpl(localDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => AddExpense(getIt()));
  getIt.registerLazySingleton(() => GetAllExpenses(getIt()));
  getIt.registerLazySingleton(() => GetExpensesByMonth(getIt()));
  getIt.registerLazySingleton(() => GetExpensesByCategory(getIt()));
  getIt.registerLazySingleton(() => UpdateExpense(getIt()));
  getIt.registerLazySingleton(() => DeleteExpense(getIt()));
  getIt.registerLazySingleton(() => GetTotalSpentByMonth(getIt()));
  getIt.registerLazySingleton(() => GetCategoryTotals(getIt()));

  getIt.registerLazySingleton(() => GetCurrentBudget(getIt()));
  getIt.registerLazySingleton(() => CreateBudget(getIt()));
  getIt.registerLazySingleton(() => UpdateBudget(getIt()));
  getIt.registerLazySingleton(() => UpdateBudgetSpending(getIt()));

  getIt.registerLazySingleton(() => GetAllMarketPrices(getIt()));
  getIt.registerLazySingleton(() => GetMarketPricesByCategory(getIt()));
  getIt.registerLazySingleton(() => GetMarketPriceByItem(getIt()));
  getIt.registerLazySingleton(() => SyncMarketPrices(getIt()));

  // BLoCs
  getIt.registerFactory(() => ExpenseBloc(
        addExpense: getIt(),
        getAllExpenses: getIt(),
        getExpensesByMonth: getIt(),
        updateExpense: getIt(),
        deleteExpense: getIt(),
        getTotalSpentByMonth: getIt(),
        getCategoryTotals: getIt(),
      ));

  getIt.registerFactory(() => BudgetBloc(
        getCurrentBudget: getIt(),
        createBudget: getIt(),
        updateBudget: getIt(),
        updateBudgetSpending: getIt(),
      ));

  getIt.registerFactory(() => MarketPriceBloc(
        getAllMarketPrices: getIt(),
        getMarketPricesByCategory: getIt(),
        syncMarketPrices: getIt(),
      ));
}
