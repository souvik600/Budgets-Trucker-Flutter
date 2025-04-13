import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mass_manager/core/constants/colors.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 2).format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  // Get month name
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(DateTime.now().year, month));
  }

  // Get current month and year
  static String getCurrentMonthYear() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  // Show confirm dialog
  static Future<bool> showConfirmDialog(
      BuildContext context,
      String title,
      String content
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Calculate meal rate
  static double calculateMealRate(double totalExpense, int totalMeals) {
    if (totalMeals == 0) return 0;
    return totalExpense / totalMeals;
  }

  // Calculate member balance
  static double calculateMemberBalance(
      double totalDeposit,
      int totalMeals,
      double mealRate
      ) {
    return totalDeposit - (totalMeals * mealRate);
  }

  // Get color based on balance
  static Color getBalanceColor(double balance) {
    if (balance > 0) return AppColors.success;
    if (balance < 0) return AppColors.error;
    return Colors.grey;
  }
}