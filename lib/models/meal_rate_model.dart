import 'package:cloud_firestore/cloud_firestore.dart';

class MealRateModel {
  final String id;
  final int year;
  final int month;
  final double totalBazaarExpense;
  final int totalMeals;
  final double mealRate;
  final DateTime calculatedAt;

  MealRateModel({
    required this.id,
    required this.year,
    required this.month,
    required this.totalBazaarExpense,
    required this.totalMeals,
    required this.mealRate,
    required this.calculatedAt,
  });

  // Create from Firestore map
  factory MealRateModel.fromMap(Map<String, dynamic> map) {
    return MealRateModel(
      id: map['id'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      month: map['month'] ?? DateTime.now().month,
      totalBazaarExpense: (map['totalBazaarExpense'] ?? 0).toDouble(),
      totalMeals: map['totalMeals'] ?? 0,
      mealRate: (map['mealRate'] ?? 0).toDouble(),
      calculatedAt: (map['calculatedAt'] as Timestamp).toDate(),
    );
  }

// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'totalBazaarExpense': totalBazaarExpense,
      'totalMeals': totalMeals,
      'mealRate': mealRate,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }
}