import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mass_manager/core/services/auth_service.dart';
import 'package:mass_manager/core/services/firestore_service.dart';
import 'package:mass_manager/models/meal_entry_model.dart';
import 'package:mass_manager/models/meal_rate_model.dart';
import 'package:mass_manager/models/user_model.dart';

// Home Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  final int year;
  final int month;

  const LoadHomeDataEvent({
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [year, month];
}

// Home States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final UserModel currentUser;
  final List<MealEntryModel> todayMeals;
  final double mealRate;
  final double totalExpenses;
  final int totalMeals;
  final double balance;
  final Map<String, double> categoryStats;

  const HomeLoadedState({
    required this.currentUser,
    required this.todayMeals,
    required this.mealRate,
    required this.totalExpenses,
    required this.totalMeals,
    required this.balance,
    required this.categoryStats,
  });

  @override
  List<Object?> get props => [
    currentUser,
    todayMeals,
    mealRate,
    totalExpenses,
    totalMeals,
    balance,
    categoryStats,
  ];
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Home Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthService authService;
  final FirestoreService firestoreService;

  HomeBloc({
    required this.authService,
    required this.firestoreService,
  }) : super(HomeInitialState()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeDataEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoadingState());

    try {
      // Get current user
      final currentUser = await authService.getCurrentUserProfile();

      // Get today's meals
      final today = DateTime.now();
      final todayMeals = await firestoreService.getMealsForDay(today).first;

      // Get meal rate for current month
      MealRateModel? mealRate = await firestoreService.getMealRateForMonth(
        event.year,
        event.month,
      );

      // If meal rate doesn't exist, calculate it
      if (mealRate == null) {
        mealRate = await firestoreService.calculateAndSaveMealRate(
          event.year,
          event.month,
        );
      }

      // Get user summary
      final userSummary = await firestoreService.getUserMonthlySummary(
        currentUser.id,
        event.year,
        event.month,
      );

      // Get category stats
      final categoryStats = await firestoreService.getExpenseStatsByCategory(
        event.year,
        event.month,
      );

      emit(HomeLoadedState(
        currentUser: currentUser,
        todayMeals: todayMeals,
        mealRate: mealRate.mealRate,
        totalExpenses: userSummary['totalExpenses'] as double,
        totalMeals: userSummary['totalMeals'] as int,
        balance: userSummary['balance'] as double,
        categoryStats: categoryStats,
      ));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }
}