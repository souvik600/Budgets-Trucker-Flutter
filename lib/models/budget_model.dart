import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final int year;
  final int month;
  final double totalBudget;
  final double bazaarBudget;
  final double utilityBudget;
  final double otherBudget;
  final String? note;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BudgetModel({
    required this.id,
    required this.year,
    required this.month,
    required this.totalBudget,
    required this.bazaarBudget,
    required this.utilityBudget,
    required this.otherBudget,
    this.note,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore map
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      month: map['month'] ?? DateTime.now().month,
      totalBudget: (map['totalBudget'] ?? 0).toDouble(),
      bazaarBudget: (map['bazaarBudget'] ?? 0).toDouble(),
      utilityBudget: (map['utilityBudget'] ?? 0).toDouble(),
      otherBudget: (map['otherBudget'] ?? 0).toDouble(),
      note: map['note'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'totalBudget': totalBudget,
      'bazaarBudget': bazaarBudget,
      'utilityBudget': utilityBudget,
      'otherBudget': otherBudget,
      'note': note,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with method for updating fields
  BudgetModel copyWith({
    double? totalBudget,
    double? bazaarBudget,
    double? utilityBudget,
    double? otherBudget,
    String? note,
  }) {
    return BudgetModel(
      id: id,
      year: year,
      month: month,
      totalBudget: totalBudget ?? this.totalBudget,
      bazaarBudget: bazaarBudget ?? this.bazaarBudget,
      utilityBudget: utilityBudget ?? this.utilityBudget,
      otherBudget: otherBudget ?? this.otherBudget,
      note: note ?? this.note,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}