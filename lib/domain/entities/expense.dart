import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool hasVAT;
  final double vatRate;
  final double vatAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.hasVAT = false,
    this.vatRate = 0.0,
    this.vatAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalAmount => amount + vatAmount;
  double get amountWithoutVAT => hasVAT ? amount : amount;

  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    bool? hasVAT,
    double? vatRate,
    double? vatAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      hasVAT: hasVAT ?? this.hasVAT,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amount,
        category,
        date,
        hasVAT,
        vatRate,
        vatAmount,
        createdAt,
        updatedAt,
      ];
}
