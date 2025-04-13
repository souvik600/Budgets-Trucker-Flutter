import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String addedBy;
  final String addedByName;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.addedBy,
    required this.addedByName,
    this.receiptUrl,
    required this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      addedBy: map['addedBy'] ?? '',
      addedByName: map['addedByName'] ?? '',
      receiptUrl: map['receiptUrl'],
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
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'receiptUrl': receiptUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with method for updating fields
  ExpenseModel copyWith({
    String? category,
    double? amount,
    DateTime? date,
    String? description,
    String? receiptUrl,
  }) {
    return ExpenseModel(
      id: id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      addedBy: addedBy,
      addedByName: addedByName,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}