import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../bloc/expense/expense_state.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_event.dart';
import '../bloc/market_price/market_price_bloc.dart';
import '../bloc/market_price/market_price_event.dart';
import 'dashboard_page.dart';
import 'expenses_page.dart';
import 'market_page.dart';
import 'budget_page.dart';
import '../../core/theme/app_theme.dart';
import '../../data/debug/database_debug_helper.dart'; // Add this import

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ExpensesPage(),
    const MarketPage(),
    const BudgetPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseBloc>().add(LoadExpensesByMonth(DateTime.now()));
      context.read<BudgetBloc>().add(LoadCurrentBudget());
      context.read<MarketPriceBloc>().add(LoadAllMarketPrices());

      // Add debug prints to see database data
      _printDatabaseData();
    });
  }

  // Add this method to print database data
  Future<void> _printDatabaseData() async {
    print('\n🔍 DEBUGGING DATABASE DATA 🔍');

    // Print all tables and data
    await DatabaseDebugHelper.printAllData();

    // Print current month expenses
    await DatabaseDebugHelper.printCurrentMonthExpenses();

    // Print budget information
    await DatabaseDebugHelper.printBudgetInfo();

    // Print category spending summary
    await DatabaseDebugHelper.printCategorySpendingSummary();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // Listen to expense changes and refresh budget
          BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseOperationSuccess) {
                // Refresh budget data when expenses change
                context.read<BudgetBloc>().add(LoadCurrentBudget());
                // Also refresh current month expenses to update totals
                context.read<ExpenseBloc>().add(LoadExpensesByMonth(DateTime.now()));
                context.read<ExpenseBloc>().add(LoadTotalSpent(DateTime.now()));
                context.read<ExpenseBloc>().add(LoadCategoryTotals(DateTime.now()));
              }
            },
          ),
        ],
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondary,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'Expenses',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up_outlined),
                  activeIcon: Icon(Icons.trending_up),
                  label: 'Market',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Budget',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
