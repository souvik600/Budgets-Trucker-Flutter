import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mass_manager/models/budget_model.dart';
import 'package:mass_manager/models/expense_model.dart';
import 'package:mass_manager/models/meal_entry_model.dart';
import 'package:mass_manager/models/meal_rate_model.dart';
import 'package:mass_manager/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get usersRef => _firestore.collection('users');
  CollectionReference get mealsRef => _firestore.collection('meals');
  CollectionReference get expensesRef => _firestore.collection('expenses');
  CollectionReference get budgetsRef => _firestore.collection('budgets');
  CollectionReference get mealRatesRef => _firestore.collection('mealRates');

  // Get all users
  Stream<List<UserModel>> getUsers() {
    return usersRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Add new user
  Future<void> addUser(UserModel user) async {
    await usersRef.doc(user.id).set(user.toMap());
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    await usersRef.doc(user.id).update(user.toMap());
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await usersRef.doc(userId).delete();
  }

  // Get meals for a specific day
  Stream<List<MealEntryModel>> getMealsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return mealsRef
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MealEntryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get meals for a specific user
  Stream<List<MealEntryModel>> getMealsForUser(String userId) {
    return mealsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MealEntryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get meals for a specific month
  Stream<List<MealEntryModel>> getMealsForMonth(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return mealsRef
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MealEntryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Add meal entry
  Future<void> addMealEntry(MealEntryModel meal) async {
    await mealsRef.doc(meal.id).set(meal.toMap());
  }

  // Update meal entry
  Future<void> updateMealEntry(MealEntryModel meal) async {
    await mealsRef.doc(meal.id).update(meal.toMap());
  }

  // Delete meal entry
  Future<void> deleteMealEntry(String mealId) async {
    await mealsRef.doc(mealId).delete();
  }
  // Get expenses for a specific month
  Stream<List<ExpenseModel>> getExpensesForMonth(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return expensesRef
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get expenses by category
  Stream<List<ExpenseModel>> getExpensesByCategory(String category, int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return expensesRef
        .where('category', isEqualTo: category)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get expenses by user
  Stream<List<ExpenseModel>> getExpensesByUser(String userId) {
    return expensesRef
        .where('addedBy', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Add expense
  Future<void> addExpense(ExpenseModel expense) async {
    await expensesRef.doc(expense.id).set(expense.toMap());
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    await expensesRef.doc(expense.id).update(expense.toMap());
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    await expensesRef.doc(expenseId).delete();
  }

  // Get budget for a specific month
  Future<BudgetModel?> getBudgetForMonth(int year, int month) async {
    final budgetId = '$year-$month';
    final doc = await budgetsRef.doc(budgetId).get();

    if (!doc.exists) return null;
    return BudgetModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Set budget for a month
  Future<void> setBudget(BudgetModel budget) async {
    final budgetId = '${budget.year}-${budget.month}';
    await budgetsRef.doc(budgetId).set(budget.toMap());
  }

  // Get meal rate for a specific month
  Future<MealRateModel?> getMealRateForMonth(int year, int month) async {
    final rateId = '$year-$month';
    final doc = await mealRatesRef.doc(rateId).get();

    if (!doc.exists) return null;
    return MealRateModel.fromMap(doc.data() as Map<String, dynamic>);
  }

// Calculate and save meal rate for a month
  Future<MealRateModel> calculateAndSaveMealRate(int year, int month) async {
    // Get all bazaar expenses for the month
    final expenses = await expensesRef
        .where('category', isEqualTo: 'Bazaar')
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, month + 1, 0, 23, 59, 59))
        .get();

    // Calculate total bazaar expense
    double totalBazaarExpense = 0;
    for (var doc in expenses.docs) {
      final expense = ExpenseModel.fromMap(doc.data() as Map<String, dynamic>);
      totalBazaarExpense += expense.amount;
    }

    // Get all meals for the month
    final meals = await mealsRef
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, month + 1, 0, 23, 59, 59))
        .get();

    // Calculate total meals
    int totalMeals = 0;
    for (var doc in meals.docs) {
      final meal = MealEntryModel.fromMap(doc.data() as Map<String, dynamic>);
      totalMeals += meal.breakfast + meal.lunch + meal.dinner;
    }

    // Calculate meal rate
    double mealRate = totalMeals > 0 ? totalBazaarExpense / totalMeals : 0;

    // Create meal rate model
    final rateModel = MealRateModel(
      id: '$year-$month',
      year: year,
      month: month,
      totalBazaarExpense: totalBazaarExpense,
      totalMeals: totalMeals,
      mealRate: mealRate,
      calculatedAt: DateTime.now(),
    );

    // Save to Firestore
    await mealRatesRef.doc(rateModel.id).set(rateModel.toMap());

    return rateModel;
  }

// Get summary data for a user for a specific month
  Future<Map<String, dynamic>> getUserMonthlySummary(String userId, int year, int month) async {
    // Get all meals for the user in the month
    final meals = await mealsRef
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, month + 1, 0, 23, 59, 59))
        .get();

    // Calculate total meals for the user
    int totalMeals = 0;
    for (var doc in meals.docs) {
      final meal = MealEntryModel.fromMap(doc.data() as Map<String, dynamic>);
      totalMeals += meal.breakfast + meal.lunch + meal.dinner;
    }

    // Get all expenses added by the user
    final expenses = await expensesRef
        .where('addedBy', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, month + 1, 0, 23, 59, 59))
        .get();

    // Calculate total expenses added by the user
    double totalExpenses = 0;
    for (var doc in expenses.docs) {
      final expense = ExpenseModel.fromMap(doc.data() as Map<String, dynamic>);
      totalExpenses += expense.amount;
    }

    // Get meal rate for the month
    final mealRate = await getMealRateForMonth(year, month);
    double rate = mealRate?.mealRate ?? 0;

    // Calculate meal cost
    double mealCost = totalMeals * rate;

    // Calculate balance
    double balance = totalExpenses - mealCost;

    return {
      'userId': userId,
      'year': year,
      'month': month,
      'totalMeals': totalMeals,
      'totalExpenses': totalExpenses,
      'mealRate': rate,
      'mealCost': mealCost,
      'balance': balance,
    };
  }

// Get monthly summary for all users
  Future<List<Map<String, dynamic>>> getAllUsersMonthlySummary(int year, int month) async {
    // Get all users
    final userDocs = await usersRef.get();
    final List<Map<String, dynamic>> summaries = [];

    // Get meal rate for the month
    final mealRate = await getMealRateForMonth(year, month);
    double rate = mealRate?.mealRate ?? 0;

    // Calculate summary for each user
    for (var userDoc in userDocs.docs) {
      final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      final summary = await getUserMonthlySummary(user.id, year, month);

      // Add user name to summary
      summary['userName'] = user.name;
      summaries.add(summary);
    }

    return summaries;
  }

// Get total expense stats by category for a month
  Future<Map<String, double>> getExpenseStatsByCategory(int year, int month) async {
    final expenses = await expensesRef
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, month + 1, 0, 23, 59, 59))
        .get();

    final Map<String, double> categoryStats = {};

    for (var doc in expenses.docs) {
      final expense = ExpenseModel.fromMap(doc.data() as Map<String, dynamic>);
      categoryStats[expense.category] = (categoryStats[expense.category] ?? 0) + expense.amount;
    }

    return categoryStats;
  }

// Get meal distribution stats for a user
  Future<Map<String, int>> getUserMealDistribution(String userId, int year, int month) async {
    final meals = await mealsRef
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, month + 1, 0, 23, 59, 59))
        .get();

    int totalBreakfast = 0;
    int totalLunch = 0;
    int totalDinner = 0;

    for (var doc in meals.docs) {
      final meal = MealEntryModel.fromMap(doc.data() as Map<String, dynamic>);
      totalBreakfast += meal.breakfast;
      totalLunch += meal.lunch;
      totalDinner += meal.dinner;
    }

    return {
      'Breakfast': totalBreakfast,
      'Lunch': totalLunch,
      'Dinner': totalDinner,
    };
  }

// Get daily meal stats for a month
  Future<Map<int, int>> getDailyMealStats(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final meals = await mealsRef
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .get();

    Map<int, int> dailyStats = {};

    // Initialize all days of the month with 0
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      dailyStats[i] = 0;
    }

    // Calculate meals for each day
    for (var doc in meals.docs) {
      final meal = MealEntryModel.fromMap(doc.data() as Map<String, dynamic>);
      final day = meal.date.day;
      dailyStats[day] = (dailyStats[day] ?? 0) + meal.breakfast + meal.lunch + meal.dinner;
    }

    return dailyStats;
  }

  // Get monthly expense trend for the last 6 months
  Future<Map<String, double>> getMonthlyExpenseTrend() async {
    Map<String, double> monthlyTrend = {};

    // Get current month and year
    final now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;

    // Calculate expenses for the last 6 months
    for (int i = 0; i < 6; i++) {
      int targetMonth = currentMonth - i;
      int targetYear = currentYear;

      // Adjust year if needed
      if (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      final startOfMonth = DateTime(targetYear, targetMonth, 1);
      final endOfMonth = DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

      // Get expenses for the month
      final expenses = await expensesRef
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      // Calculate total expenses
      double totalExpense = 0;
      for (var doc in expenses.docs) {
        final expense = ExpenseModel.fromMap(doc.data() as Map<String, dynamic>);
        totalExpense += expense.amount;
      }

      // Format month name
      String monthName = '';
      switch (targetMonth) {
        case 1: monthName = 'Jan'; break;
        case 2: monthName = 'Feb'; break;
        case 3: monthName = 'Mar'; break;
        case 4: monthName = 'Apr'; break;
        case 5: monthName = 'May'; break;
        case 6: monthName = 'Jun'; break;
        case 7: monthName = 'Jul'; break;
        case 8: monthName = 'Aug'; break;
        case 9: monthName = 'Sep'; break;
        case 10: monthName = 'Oct'; break;
        case 11: monthName = 'Nov'; break;
        case 12: monthName = 'Dec'; break;
      }

      monthlyTrend['$monthName $targetYear'] = totalExpense;
    }

    return monthlyTrend;
  }

  // Get meal rate trend for the last 6 months
  Future<Map<String, double>> getMealRateTrend() async {
    Map<String, double> rateTrend = {};

    // Get current month and year
    final now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;

    // Get meal rates for the last 6 months
    for (int i = 0; i < 6; i++) {
      int targetMonth = currentMonth - i;
      int targetYear = currentYear;

      // Adjust year if needed
      if (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      // Get meal rate for the month
      final mealRate = await getMealRateForMonth(targetYear, targetMonth);
      double rate = mealRate?.mealRate ?? 0;

      // Format month name
      String monthName = '';
      switch (targetMonth) {
        case 1: monthName = 'Jan'; break;
        case 2: monthName = 'Feb'; break;
        case 3: monthName = 'Mar'; break;
        case 4: monthName = 'Apr'; break;
        case 5: monthName = 'May'; break;
        case 6: monthName = 'Jun'; break;
        case 7: monthName = 'Jul'; break;
        case 8: monthName = 'Aug'; break;
        case 9: monthName = 'Sep'; break;
        case 10: monthName = 'Oct'; break;
        case 11: monthName = 'Nov'; break;
        case 12: monthName = 'Dec'; break;
      }

      rateTrend['$monthName $targetYear'] = rate;
    }

    return rateTrend;
  }

  // Get user contribution percentage for a month
  Future<Map<String, double>> getUserContributionPercentage(int year, int month) async {
    // Get all expenses for the month
    final expenses = await expensesRef
        .where('date', isGreaterThanOrEqualTo: DateTime(year, month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(year, month + 1, 0, 23, 59, 59))
        .get();

    // Calculate total expenses and user contributions
    double totalExpenses = 0;
    Map<String, double> userContributions = {};

    for (var doc in expenses.docs) {
      final expense = ExpenseModel.fromMap(doc.data() as Map<String, dynamic>);
      totalExpenses += expense.amount;
      userContributions[expense.addedBy] = (userContributions[expense.addedBy] ?? 0) + expense.amount;
    }

    // Calculate percentage contributions
    Map<String, double> percentageContributions = {};

    if (totalExpenses > 0) {
      await Future.forEach(userContributions.keys, (String userId) async {
        final user = await getUserById(userId);
        if (user != null) {
          percentageContributions[user.name] = (userContributions[userId]! / totalExpenses) * 100;
        }
      });
    }

    return percentageContributions;
  }
}