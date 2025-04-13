import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:mass_manager/core/services/firestore_service.dart';
import 'package:mass_manager/models/expense_model.dart';

// Expense Events
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpensesEvent extends ExpenseEvent {
  final int year;
  final int month;

  const LoadExpensesEvent({
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [year, month];
}

class LoadExpensesByCategoryEvent extends ExpenseEvent {
  final String category;
  final int year;
  final int month;

  const LoadExpensesByCategoryEvent({
    required this.category,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [category, year, month];
}

class AddExpenseEvent extends ExpenseEvent {
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String addedBy;
  final String addedByName;
  final String? receiptUrl;

  const AddExpenseEvent({
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.addedBy,
    required this.addedByName,
    this.receiptUrl,
  });

  @override
  List<Object?> get props => [
    category,
    amount,
    date,
    description,
    addedBy,
    addedByName,
    receiptUrl,
  ];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final ExpenseModel expense;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String? receiptUrl;

  const UpdateExpenseEvent({
    required this.expense,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    this.receiptUrl,
  });
  @override
  List<Object?> get props => [
    expense,
    category,
    amount,
    date,
    description,
    receiptUrl,
  ];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String expenseId;

  const DeleteExpenseEvent({required this.expenseId});

  @override
  List<Object?> get props => [expenseId];
}

// Expense States
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitialState extends ExpenseState {}

class ExpenseLoadingState extends ExpenseState {}

class ExpensesLoadedState extends ExpenseState {
  final List<ExpenseModel> expenses;
  final double totalAmount;

  const ExpensesLoadedState({
    required this.expenses,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [expenses, totalAmount];
}

class ExpenseOperationSuccessState extends ExpenseState {
  final String message;

  const ExpenseOperationSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ExpenseErrorState extends ExpenseState {
  final String message;

  const ExpenseErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Expense Bloc
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final FirestoreService firestoreService;

  ExpenseBloc({required this.firestoreService}) : super(ExpenseInitialState()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<LoadExpensesByCategoryEvent>(_onLoadExpensesByCategory);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
      LoadExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(ExpenseLoadingState());

    try {
      final expenses = await firestoreService.getExpensesForMonth(
        event.year,
        event.month,
      ).first;

      final totalAmount = expenses.fold<double>(
        0,
            (sum, expense) => sum + expense.amount,
      );

      emit(ExpensesLoadedState(
        expenses: expenses,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(ExpenseErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadExpensesByCategory(
      LoadExpensesByCategoryEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(ExpenseLoadingState());

    try {
      final expenses = await firestoreService.getExpensesByCategory(
        event.category,
        event.year,
        event.month,
      ).first;

      final totalAmount = expenses.fold<double>(
        0,
            (sum, expense) => sum + expense.amount,
      );

      emit(ExpensesLoadedState(
        expenses: expenses,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(ExpenseErrorState(message: e.toString()));
    }
  }

  Future<void> _onAddExpense(
      AddExpenseEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(ExpenseLoadingState());

    try {
      final newExpense = ExpenseModel(
        id: const Uuid().v4(),
        category: event.category,
        amount: event.amount,
        date: event.date,
        description: event.description,
        addedBy: event.addedBy,
        addedByName: event.addedByName,
        receiptUrl: event.receiptUrl,
        createdAt: DateTime.now(),
      );

      await firestoreService.addExpense(newExpense);

      // Recalculate meal rate for the month
      await firestoreService.calculateAndSaveMealRate(
        event.date.year,
        event.date.month,
      );

      emit(const ExpenseOperationSuccessState(
        message: 'Expense added successfully',
      ));
    } catch (e) {
      emit(ExpenseErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpenseEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(ExpenseLoadingState());

    try {
      final updatedExpense = event.expense.copyWith(
        category: event.category,
        amount: event.amount,
        date: event.date,
        description: event.description,
        receiptUrl: event.receiptUrl,
      );

      await firestoreService.updateExpense(updatedExpense);

      // Recalculate meal rate for the month
      await firestoreService.calculateAndSaveMealRate(
        event.date.year,
        event.date.month,
      );

      emit(const ExpenseOperationSuccessState(
        message: 'Expense updated successfully',
      ));
    } catch (e) {
      emit(ExpenseErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpenseEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(ExpenseLoadingState());

    try {
      // Get the expense to determine its month for meal rate recalculation
      final expenses = await firestoreService.expensesRef.doc(event.expenseId).get();
      final expense = ExpenseModel.fromMap(expenses.data() as Map<String, dynamic>);

      await firestoreService.deleteExpense(event.expenseId);

      // Recalculate meal rate for the month
      await firestoreService.calculateAndSaveMealRate(
        expense.date.year,
        expense.date.month,
      );

      emit(const ExpenseOperationSuccessState(
        message: 'Expense deleted successfully',
      ));
    } catch (e) {
      emit(ExpenseErrorState(message: e.toString()));
    }
  }
}