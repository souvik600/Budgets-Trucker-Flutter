import 'package:flutter/material.dart';
import 'package:mass_manager/features/auth/screens/login_screen.dart';
import 'package:mass_manager/features/auth/screens/register_screen.dart';
import 'package:mass_manager/features/expenses/screens/add_expense_screen.dart';
import 'package:mass_manager/features/expenses/screens/expense_list_screen.dart';
import 'package:mass_manager/features/home/screens/home_screen.dart';
import 'package:mass_manager/features/meals/screens/meal_input_screen.dart';
import 'package:mass_manager/features/members/screens/manage_members_screen.dart';
import 'package:mass_manager/features/reports/screens/reports_screen.dart';
import 'package:mass_manager/features/splash/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String mealInput = '/meal-input';
  static const String addExpense = '/add-expense';
  static const String expenseList = '/expense-list';
  static const String manageMembers = '/manage-members';
  static const String reports = '/reports';
  static const String settings = '/settings';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case mealInput:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MealInputScreen(
            userId: args?['userId'],
            date: args?['date'],
          ),
        );

      case addExpense:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddExpenseScreen(
            expenseId: args?['expenseId'],
          ),
        );

      case expenseList:
        return MaterialPageRoute(builder: (_) => const ExpenseListScreen());

      case manageMembers:
        return MaterialPageRoute(builder: (_) => const ManageMembersScreen());

      case reports:
       return MaterialPageRoute(builder: (_) => const ReportsScreen());

      // case settings:
      //   return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}