class AppConstants {
  // App Info
  static const String appName = 'CoinLeaf';
  static const String appTagline = 'Track. Save. Thrive';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'coinleaf.db';
  static const int databaseVersion = 1;

  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String budgetKey = 'monthly_budget';
  static const String currencyKey = 'currency';
  static const String themeKey = 'theme_mode';

  // Default Values
  static const double defaultBudget = 1000.0;
  static const String defaultCurrency = 'USD';

  // Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Bills & Utilities',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Education',
    'Others'
  ];

  // Market Items
  static const List<String> marketItems = [
    'Rice',
    'Wheat',
    'Vegetables',
    'Fruits',
    'Cooking Oil',
    'Sugar',
    'Milk',
    'Eggs',
    'Chicken',
    'Fish'
  ];

  // API Endpoints (for future implementation)
  static const String baseUrl = 'https://api.coinleaf.com';
  static const String marketPricesEndpoint = '/market-prices';

  // UI Constants
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
}
