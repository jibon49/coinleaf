import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final double monthlyLimit;
  final double currentSpent;
  final DateTime month;
  final Map<String, double> categoryLimits;
  final Map<String, double> categorySpent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.monthlyLimit,
    this.currentSpent = 0.0,
    required this.month,
    this.categoryLimits = const {},
    this.categorySpent = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingBudget => monthlyLimit - currentSpent;
  double get spentPercentage => monthlyLimit > 0 ? (currentSpent / monthlyLimit) * 100 : 0;
  bool get isOverBudget => currentSpent > monthlyLimit;
  bool get isNearLimit => spentPercentage >= 80;

  double getCategorySpent(String category) => categorySpent[category] ?? 0.0;
  double getCategoryLimit(String category) => categoryLimits[category] ?? 0.0;
  double getCategoryRemaining(String category) {
    final limit = getCategoryLimit(category);
    final spent = getCategorySpent(category);
    return limit - spent;
  }

  Budget copyWith({
    String? id,
    double? monthlyLimit,
    double? currentSpent,
    DateTime? month,
    Map<String, double>? categoryLimits,
    Map<String, double>? categorySpent,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currentSpent: currentSpent ?? this.currentSpent,
      month: month ?? this.month,
      categoryLimits: categoryLimits ?? this.categoryLimits,
      categorySpent: categorySpent ?? this.categorySpent,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        monthlyLimit,
        currentSpent,
        month,
        categoryLimits,
        categorySpent,
        isActive,
        createdAt,
        updatedAt,
      ];
}
