import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_state.dart';
import '../bloc/budget/budget_event.dart';
import '../widgets/budget_progress_card.dart';
import '../../domain/entities/budget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/utils.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(LoadCurrentBudget());
  }

  void _showEditBudgetDialog(Budget? currentBudget) {
    final monthlyLimitController = TextEditingController(
      text: currentBudget?.monthlyLimit.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentBudget == null ? 'Set Monthly Budget' : 'Edit Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: monthlyLimitController,
              decoration: const InputDecoration(
                labelText: 'Monthly Budget Limit',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'This will be your spending limit for the month.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(monthlyLimitController.text);
              if (amount != null && amount > 0) {
                final now = DateTime.now();
                final budget = Budget(
                  id: currentBudget?.id ?? const Uuid().v4(),
                  monthlyLimit: amount,
                  currentSpent: currentBudget?.currentSpent ?? 0.0,
                  month: DateTime(now.year, now.month),
                  categoryLimits: currentBudget?.categoryLimits ?? {},
                  categorySpent: currentBudget?.categorySpent ?? {},
                  isActive: true,
                  createdAt: currentBudget?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (currentBudget == null) {
                  context.read<BudgetBloc>().add(CreateBudgetEvent(budget));
                } else {
                  context.read<BudgetBloc>().add(UpdateBudgetEvent(budget));
                }
                Navigator.pop(context);
              }
            },
            child: Text(currentBudget == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              final state = context.read<BudgetBloc>().state;
              final currentBudget = state is BudgetLoaded ? state.budget : null;
              _showEditBudgetDialog(currentBudget);
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Budget',
          ),
        ],
      ),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading budget',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BudgetBloc>().add(LoadCurrentBudget());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is BudgetLoaded) {
            final budget = state.budget;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Progress Card
                  BudgetProgressCard(budget: budget),
                  const SizedBox(height: 24),

                  // Budget Tips
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppTheme.accentColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Budget Tips',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTip(
                          '50/30/20 Rule',
                          '50% needs, 30% wants, 20% savings',
                          Icons.pie_chart,
                        ),
                        const SizedBox(height: 12),
                        _buildTip(
                          'Track Daily',
                          'Record expenses daily for better control',
                          Icons.calendar_today,
                        ),
                        const SizedBox(height: 12),
                        _buildTip(
                          'Emergency Fund',
                          'Save 3-6 months of expenses',
                          Icons.security,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  if (budget.categorySpent.isNotEmpty) ...[
                    Text(
                      'Category Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: budget.categorySpent.entries.map((entry) {
                          final category = entry.key;
                          final spent = entry.value;
                          final limit = budget.getCategoryLimit(category);
                          final percentage = limit > 0 ? (spent / limit) * 100 : 0.0;

                          Color progressColor;
                          if (percentage >= 90) {
                            progressColor = AppTheme.errorColor;
                          } else if (percentage >= 70) {
                            progressColor = AppTheme.warningColor;
                          } else {
                            progressColor = AppTheme.successColor;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      CurrencyUtils.formatCurrency(spent),
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: progressColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (limit > 0) ...[
                                  LinearProgressIndicator(
                                    value: (percentage / 100).clamp(0.0, 1.0),
                                    backgroundColor: AppTheme.dividerColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${percentage.toStringAsFixed(0)}% of limit',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        'Limit: ${CurrencyUtils.formatCurrency(limit)}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Text(
                                    'No limit set',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTip(String title, String description, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
