import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../bloc/expense/expense_state.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_event.dart';
import '../bloc/budget/budget_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart' as app_utils;
import '../../domain/entities/budget.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  int _selectedYear = DateTime.now().year;
  // Cache to prevent flicker when state becomes loading or unrelated year updates arrive
  Map<int, double> _monthlyTotalsCache = {};
  bool _isExpenseLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  void _loadSummaryData() {
    context.read<ExpenseBloc>().add(LoadSummaryData(_selectedYear));
    context.read<BudgetBloc>().add(LoadBudgetSummaryData(_selectedYear));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Summary',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onSelected: (year) {
              setState(() {
                _selectedYear = year;
              });
              _loadSummaryData();
            },
            itemBuilder: (context) {
              final currentYear = DateTime.now().year;
              return List.generate(5, (index) {
                final year = currentYear - index;
                return PopupMenuItem<int>(
                  value: year,
                  child: Text('$year'),
                );
              });
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  '$_selectedYear Summary',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Yearly Overview Cards
                _buildYearlyOverview(),
                const SizedBox(height: 20),

                // Monthly Breakdown Chart
                _buildMonthlyChart(),
                const SizedBox(height: 20),

                // Savings Summary
                _buildSavingsSummary(),
                const SizedBox(height: 20),

                // Monthly Savings Breakdown
                _buildMonthlySavingsBreakdown(),
                const SizedBox(height: 20),

                // Financial Goals Progress
                _buildFinancialGoalsProgress(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyOverview() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        double yearlyTotal = 0;
        int totalTransactions = 0;
        double averageMonthly = 0;

        if (state is YearlyExpenseLoaded) {
          yearlyTotal = state.yearlyTotal;
          totalTransactions = state.expenses.length;
          averageMonthly = yearlyTotal / 12;
        } else if (state is YearlyExpenseWithMonthlyTotals) {
          yearlyTotal = state.yearlyTotal;
          totalTransactions = state.expenses.length;
          averageMonthly = yearlyTotal / 12;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Yearly Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Total Spent',
                      app_utils.CurrencyUtils.formatCurrency(yearlyTotal),
                      Icons.trending_up,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      'Transactions',
                      totalTransactions.toString(),
                      Icons.receipt,
                      AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildOverviewCard(
                'Average Monthly',
                app_utils.CurrencyUtils.formatCurrency(averageMonthly),
                Icons.calendar_month,
                Colors.orange,
                isFullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: isFullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildMonthlyChart() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      buildWhen: (prev, curr) {
        // Always rebuild on initial load and when summary data for selected year arrives.
        if (curr is YearlyExpenseWithMonthlyTotals && curr.year == _selectedYear) return true;
        if (curr is ExpenseLoading) return true;
        if (curr is MonthlyTotalsLoaded) {
          // Only rebuild if it matches the selected year to avoid clobbering with other years
          return curr.year == _selectedYear;
        }
        if (curr is ExpenseError) return true;
        return false;
      },
      builder: (context, state) {
        // Update cache/loading flags based on state
        if (state is ExpenseLoading) {
          _isExpenseLoading = true;
        } else if (state is YearlyExpenseWithMonthlyTotals && state.year == _selectedYear) {
          _monthlyTotalsCache = state.monthlyTotals;
          _isExpenseLoading = false;
        } else if (state is MonthlyTotalsLoaded && state.year == _selectedYear) {
          _monthlyTotalsCache = state.monthlyTotals;
          _isExpenseLoading = false;
        } else if (state is ExpenseError) {
          _isExpenseLoading = false;
        }

        final monthlyTotals = _monthlyTotalsCache;

        // Calculate max value for proper scaling
        double maxValue = 0;
        for (int i = 1; i <= 12; i++) {
          final amount = monthlyTotals[i] ?? 0;
          if (amount > maxValue) maxValue = amount;
        }
        if (maxValue == 0) maxValue = 1000; // minimum scale
        maxValue = maxValue * 1.2; // padding for visualization

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (monthlyTotals.isNotEmpty)
                    Text(
                      'Max: ${app_utils.CurrencyUtils.formatCurrency(maxValue / 1.2)}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: () {
                  if (_isExpenseLoading && monthlyTotals.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (monthlyTotals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expense data available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some expenses to see the monthly breakdown',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: 12,
                      minY: 0,
                      maxY: maxValue,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxValue / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withValues(alpha: 0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            interval: maxValue / 4,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const Text('0');
                              return Text(
                                app_utils.CurrencyUtils.formatCurrency(value).replaceAll('৳', ''),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              final index = value.toInt() - 1;
                              if (index >= 0 && index < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    months[index],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          left: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(12, (index) {
                            final month = index + 1;
                            final amount = monthlyTotals[month] ?? 0;
                            return FlSpot(month.toDouble(), amount);
                          }),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: AppTheme.primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              final month = index + 1;
                              final hasData = monthlyTotals.containsKey(month) && (monthlyTotals[month] ?? 0) > 0;

                              return FlDotCirclePainter(
                                radius: hasData ? 5 : 3,
                                color: hasData ? AppTheme.primaryColor : Colors.grey.shade400,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.15),
                                AppTheme.primaryColor.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final month = barSpot.x.toInt();
                              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              final monthName = months[month - 1];
                              final amount = barSpot.y;

                              return LineTooltipItem(
                                '$monthName\n${app_utils.CurrencyUtils.formatCurrency(amount)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    );
                }(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavingsSummary() {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        double yearlySavings = 0;
        List<Budget> yearlyBudgets = [];

        // Handle both old and new states for backward compatibility
        if (budgetState is YearlySavingsLoaded) {
          yearlySavings = budgetState.yearlySavings;
        } else if (budgetState is BudgetSummaryLoaded) {
          yearlySavings = budgetState.yearlySavings;
          yearlyBudgets = budgetState.yearlyBudgets;
        } else if (budgetState is YearlyBudgetsLoaded) {
          // Calculate yearly savings from budget data
          for (final budget in budgetState.yearlyBudgets) {
            yearlySavings += (budget.monthlyLimit - budget.currentSpent);
          }
          yearlyBudgets = budgetState.yearlyBudgets;
        }

        if (yearlySavings == 0 && yearlyBudgets.isEmpty && budgetState is! BudgetLoading) {
          // Show no data state
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No budget data for $_selectedYear',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Set monthly budgets to see your savings summary',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (budgetState is BudgetLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading savings data...'),
              ],
            ),
          );
        }

        final monthlySavings = yearlySavings / 12;
        double totalYearlyBudget = 0;

        // Calculate total yearly budget
        for (final budget in yearlyBudgets) {
          totalYearlyBudget += budget.monthlyLimit;
        }

        final savingsRate = totalYearlyBudget > 0 ? (yearlySavings / totalYearlyBudget) * 100 : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                yearlySavings >= 0 ? Colors.green.shade400 : Colors.red.shade400,
                yearlySavings >= 0 ? Colors.green.shade600 : Colors.red.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (yearlySavings >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      yearlySavings >= 0 ? Icons.savings : Icons.trending_down,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    yearlySavings >= 0 ? 'Savings Summary' : 'Overspending Alert',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSavingsCard(
                      'Yearly ${yearlySavings >= 0 ? "Savings" : "Overspent"}',
                      app_utils.CurrencyUtils.formatCurrency(yearlySavings.abs()),
                      '${savingsRate.abs().toStringAsFixed(1)}% of budget',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSavingsCard(
                      'Monthly Avg',
                      app_utils.CurrencyUtils.formatCurrency(monthlySavings.abs()),
                      yearlySavings >= 0 ? 'Saved per month' : 'Over per month',
                    ),
                  ),
                ],
              ),
              if (yearlyBudgets.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget set for ${yearlyBudgets.length} months',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Total: ${app_utils.CurrencyUtils.formatCurrency(totalYearlyBudget)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavingsCard(String title, String amount, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySavingsBreakdown() {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        Map<int, double> monthlySavingsData = {};

        // Handle both old and new states for backward compatibility
        if (budgetState is MonthlySavingsBreakdownLoaded) {
          monthlySavingsData = budgetState.monthlySavings;
        } else if (budgetState is BudgetSummaryLoaded) {
          monthlySavingsData = budgetState.monthlySavings;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Savings Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${monthlySavingsData.length} months with data',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (monthlySavingsData.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (budgetState is BudgetLoading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Loading monthly savings data...'),
                      ] else ...[
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No monthly budget data for $_selectedYear',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create monthly budgets to track your savings progress',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                ...monthlySavingsData.entries.map((entry) {
                  final month = entry.key;
                  final savings = entry.value;
                  final monthName = const [
                    '', 'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'
                  ][month];

                  // Calculate percentage based on savings amount
                  final maxSavings = monthlySavingsData.values.isNotEmpty
                      ? monthlySavingsData.values.reduce((a, b) => a.abs() > b.abs() ? a : b).abs()
                      : 1000.0;
                  final savingsPercentage = maxSavings > 0 ? (savings.abs() / maxSavings) * 100 : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMonthlySavingsRow(
                      monthName,
                      savings,
                      savingsPercentage.clamp(0.0, 100.0).toDouble()
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialGoalsProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.track_changes,
                  color: Colors.purple.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Financial Goals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGoalProgress('Emergency Fund', 50000, 30000, Colors.blue),
          const SizedBox(height: 16),
          _buildGoalProgress('Vacation Fund', 25000, 15000, Colors.orange),
          const SizedBox(height: 16),
          _buildGoalProgress('Investment', 100000, 45000, Colors.green),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(String goal, double target, double current, Color color) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              goal,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              app_utils.CurrencyUtils.formatCurrency(current),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              app_utils.CurrencyUtils.formatCurrency(target),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlySavingsRow(String month, double saved, double percentage) {
    final isPositive = saved >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            month,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: (percentage.abs() / 100).clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            app_utils.CurrencyUtils.formatCurrency(saved.abs()),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
