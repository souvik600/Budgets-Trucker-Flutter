import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:mass_manager/core/services/firestore_service.dart';
import 'package:mass_manager/models/meal_entry_model.dart';

// Meal Events
abstract class MealEvent extends Equatable {
  const MealEvent();

  @override
  List<Object?> get props => [];
}

class LoadMealsEvent extends MealEvent {
  final DateTime date;

  const LoadMealsEvent({required this.date});

  @override
  List<Object?> get props => [date];
}

class LoadUserMealsEvent extends MealEvent {
  final String userId;

  const LoadUserMealsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddMealEntryEvent extends MealEvent {
  final String userId;
  final String userName;
  final DateTime date;
  final int breakfast;
  final int lunch;
  final int dinner;
  final String? note;

  const AddMealEntryEvent({
    required this.userId,
    required this.userName,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.note,
  });

  @override
  List<Object?> get props => [userId, date, breakfast, lunch, dinner, note];
}

class UpdateMealEntryEvent extends MealEvent {
  final MealEntryModel meal;
  final int breakfast;
  final int lunch;
  final int dinner;
  final String? note;

  const UpdateMealEntryEvent({
    required this.meal,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.note,

  });

  @override
  List<Object?> get props => [meal, breakfast, lunch, dinner, note];
}

class DeleteMealEntryEvent extends MealEvent {
  final String mealId;

  const DeleteMealEntryEvent({required this.mealId});

  @override
  List<Object?> get props => [mealId];
}

// Meal States
abstract class MealState extends Equatable {
  const MealState();

  @override
  List<Object?> get props => [];
}

class MealInitialState extends MealState {}

class MealLoadingState extends MealState {}

class MealsLoadedState extends MealState {
  final List<MealEntryModel> meals;

  const MealsLoadedState({required this.meals});

  @override
  List<Object?> get props => [meals];
}

class MealOperationSuccessState extends MealState {
  final String message;

  const MealOperationSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MealErrorState extends MealState {
  final String message;

  const MealErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Meal Bloc
class MealBloc extends Bloc<MealEvent, MealState> {
  final FirestoreService firestoreService;
  late String _userId;

  MealBloc({required this.firestoreService}) : super(MealInitialState()) {
    on<LoadMealsEvent>(_onLoadMeals);
    on<LoadUserMealsEvent>(_onLoadUserMeals);
    on<AddMealEntryEvent>(_onAddMealEntry);
    on<UpdateMealEntryEvent>(_onUpdateMealEntry);
    on<DeleteMealEntryEvent>(_onDeleteMealEntry);
  }

  Future<void> _onLoadMeals(
      LoadMealsEvent event,
      Emitter<MealState> emit,
      ) async {
    emit(MealLoadingState());

    try {
      final meals = await firestoreService.getMealsForDay(event.date).first;
      emit(MealsLoadedState(meals: meals));
    } catch (e) {
      emit(MealErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadUserMeals(
      LoadUserMealsEvent event,
      Emitter<MealState> emit,
      ) async {
    emit(MealLoadingState());

    try {
      final meals = await firestoreService.getMealsForUser(event.userId).first;
      emit(MealsLoadedState(meals: meals));
    } catch (e) {
      emit(MealErrorState(message: e.toString()));
    }
  }

  Future<void> _onAddMealEntry(
      AddMealEntryEvent event,
      Emitter<MealState> emit,
      ) async {
    emit(MealLoadingState());

    try {
      // Check if meal entry already exists for this user and date
      final meals = await firestoreService.getMealsForDay(event.date).first;
      final existingMeal = meals.any((meal) => meal.userId == _userId)
          ? meals.firstWhere((meal) => meal.userId == _userId)
          : null;

      if (existingMeal != null) {
        // Update existing meal
        await firestoreService.updateMealEntry(
          existingMeal.copyWith(
            breakfast: event.breakfast,
            lunch: event.lunch,
            dinner: event.dinner,
            note: event.note,
          ),
        );

        emit(const MealOperationSuccessState(
          message: 'Meal entry updated successfully',
        ));
      } else {
        // Create new meal entry
        final newMeal = MealEntryModel(
          id: const Uuid().v4(),
          userId: event.userId,
          userName: event.userName,
          date: DateTime(event.date.year, event.date.month, event.date.day),
          breakfast: event.breakfast,
          lunch: event.lunch,
          dinner: event.dinner,
          note: event.note,
          createdAt: DateTime.now(),
        );

        await firestoreService.addMealEntry(newMeal);

        emit(const MealOperationSuccessState(
          message: 'Meal entry added successfully',
        ));
      }
    } catch (e) {
      emit(MealErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateMealEntry(
      UpdateMealEntryEvent event,
      Emitter<MealState> emit,
      ) async {
    emit(MealLoadingState());

    try {
      final updatedMeal = event.meal.copyWith(
        breakfast: event.breakfast,
        lunch: event.lunch,
        dinner: event.dinner,
        note: event.note,
      );

      await firestoreService.updateMealEntry(updatedMeal);

      emit(const MealOperationSuccessState(
        message: 'Meal entry updated successfully',
      ));
    } catch (e) {
      emit(MealErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteMealEntry(
      DeleteMealEntryEvent event,
      Emitter<MealState> emit,
      ) async {
    emit(MealLoadingState());

    try {
      await firestoreService.deleteMealEntry(event.mealId);

      emit(const MealOperationSuccessState(
        message: 'Meal entry deleted successfully',
      ));
    } catch (e) {
      emit(MealErrorState(message: e.toString()));
    }
  }
}