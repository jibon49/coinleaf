import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'core/theme/app_theme.dart';
import 'dependency_injection.dart';
import 'presentation/bloc/expense/expense_bloc.dart';
import 'presentation/bloc/budget/budget_bloc.dart';
import 'presentation/bloc/market_price/market_price_bloc.dart';
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Ensure SQLite is available
    await databaseFactory.getDatabasesPath();

    // Setup dependency injection (this will also initialize the database)
    await setupDependencyInjection();

    runApp(const CoinLeafApp());
  } catch (e) {
    print('Error during app initialization: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class CoinLeafApp extends StatelessWidget {
  const CoinLeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (context) => getIt<ExpenseBloc>(),
        ),
        BlocProvider<BudgetBloc>(
          create: (context) => getIt<BudgetBloc>(),
        ),
        BlocProvider<MarketPriceBloc>(
          create: (context) => getIt<MarketPriceBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'CoinLeaf',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App Initialization Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
