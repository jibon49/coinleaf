import 'package:flutter/material.dart';
import '../../data/debug/database_debug_helper.dart';
import '../../data/datasources/database_helper.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _budgets = [];
  List<Map<String, dynamic>> _marketPrices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final expenses = await db.query('expenses', orderBy: 'date DESC');
      final budgets = await db.query('budgets', orderBy: 'month DESC');
      final marketPrices = await db.query('market_prices', orderBy: 'item_name');

      setState(() {
        _expenses = expenses;
        _budgets = budgets;
        _marketPrices = marketPrices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              // Print debug info to console
              await DatabaseDebugHelper.printAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Debug info printed to console')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Expenses', icon: Icon(Icons.receipt)),
                      Tab(text: 'Budgets', icon: Icon(Icons.account_balance_wallet)),
                      Tab(text: 'Market Prices', icon: Icon(Icons.trending_up)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildExpensesTab(),
                        _buildBudgetsTab(),
                        _buildMarketPricesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildExpensesTab() {
    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(expense['title'] ?? 'No Title'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: \$${expense['amount']?.toStringAsFixed(2) ?? '0.00'}'),
                Text('Category: ${expense['category'] ?? 'Unknown'}'),
                Text('Date: ${expense['date'] ?? 'Unknown'}'),
                if (expense['description'] != null && expense['description'].toString().isNotEmpty)
                  Text('Description: ${expense['description']}'),
              ],
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID: ${expense['id']}'),
                if (expense['has_vat'] == 1)
                  const Icon(Icons.local_atm, color: Colors.orange, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetsTab() {
    return ListView.builder(
      itemCount: _budgets.length,
      itemBuilder: (context, index) {
        final budget = _budgets[index];
        final monthlyLimit = budget['monthly_limit'] as double? ?? 0.0;
        final currentSpent = budget['current_spent'] as double? ?? 0.0;
        final remaining = monthlyLimit - currentSpent;

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('Budget - ${budget['month'] ?? 'Unknown Month'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Limit: \$${monthlyLimit.toStringAsFixed(2)}'),
                Text('Current Spent: \$${currentSpent.toStringAsFixed(2)}'),
                Text('Remaining: \$${remaining.toStringAsFixed(2)}'),
                Text('Active: ${budget['is_active'] == 1 ? 'Yes' : 'No'}'),
                Text('Created: ${budget['created_at'] ?? 'Unknown'}'),
              ],
            ),
            trailing: Text('ID: ${budget['id']}'),
          ),
        );
      },
    );
  }

  Widget _buildMarketPricesTab() {
    return ListView.builder(
      itemCount: _marketPrices.length,
      itemBuilder: (context, index) {
        final price = _marketPrices[index];
        final currentPrice = price['price'] as double? ?? 0.0;
        final previousPrice = price['previous_price'] as double? ?? 0.0;
        final priceChange = price['price_change'] as double? ?? 0.0;

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(price['item_name'] ?? 'Unknown Item'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: \$${currentPrice.toStringAsFixed(2)} per ${price['unit'] ?? 'unit'}'),
                Text('Previous: \$${previousPrice.toStringAsFixed(2)}'),
                Text('Change: ${priceChange >= 0 ? '+' : ''}\$${priceChange.toStringAsFixed(2)}'),
                Text('Location: ${price['location'] ?? 'Unknown'}'),
                Text('Updated: ${price['last_updated'] ?? 'Unknown'}'),
              ],
            ),
            trailing: Icon(
              priceChange >= 0 ? Icons.trending_up : Icons.trending_down,
              color: priceChange >= 0 ? Colors.red : Colors.green,
            ),
          ),
        );
      },
    );
  }
}
