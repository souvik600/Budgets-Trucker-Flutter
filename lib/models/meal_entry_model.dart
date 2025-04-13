import 'package:cloud_firestore/cloud_firestore.dart';

class MealEntryModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final int breakfast;
  final int lunch;
  final int dinner;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MealEntryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore map
  factory MealEntryModel.fromMap(Map<String, dynamic> map) {
    return MealEntryModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      breakfast: map['breakfast'] ?? 0,
      lunch: map['lunch'] ?? 0,
      dinner: map['dinner'] ?? 0,
      note: map['note'],
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
      'userId': userId,
      'userName': userName,
      'date': Timestamp.fromDate(date),
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Get total meals
  int get totalMeals => breakfast + lunch + dinner;

  // Copy with method for updating fields
  MealEntryModel copyWith({
    int? breakfast,
    int? lunch,
    int? dinner,
    String? note,
  }) {
    return MealEntryModel(
        id: id,
        userId: userId,
        userName: userName,
        date: date,
        breakfast: breakfast ?? this.breakfast,
        lunch: lunch ?? this.lunch,
        dinner: dinner ?? this.dinner,
        note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}