import 'dart:convert';
import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.monthlyLimit,
    super.currentSpent,
    required super.month,
    super.categoryLimits,
    super.categorySpent,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      monthlyLimit: (json['monthly_limit'] as num).toDouble(),
      currentSpent: (json['current_spent'] as num?)?.toDouble() ?? 0.0,
      month: DateTime.parse(json['month'] as String),
      categoryLimits: json['category_limits'] != null
          ? Map<String, double>.from(
              jsonDecode(json['category_limits'] as String)
                  .map((key, value) => MapEntry(key, (value as num).toDouble())))
          : {},
      categorySpent: json['category_spent'] != null
          ? Map<String, double>.from(
              jsonDecode(json['category_spent'] as String)
                  .map((key, value) => MapEntry(key, (value as num).toDouble())))
          : {},
      isActive: json['is_active'] == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthly_limit': monthlyLimit,
      'current_spent': currentSpent,
      'month': month.toIso8601String(),
      'category_limits': jsonEncode(categoryLimits),
      'category_spent': jsonEncode(categorySpent),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      monthlyLimit: budget.monthlyLimit,
      currentSpent: budget.currentSpent,
      month: budget.month,
      categoryLimits: budget.categoryLimits,
      categorySpent: budget.categorySpent,
      isActive: budget.isActive,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }
}
