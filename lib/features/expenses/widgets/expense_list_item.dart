import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/utils/helpers.dart';
import 'package:mass_manager/models/expense_model.dart';

class ExpenseListItem extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor;
    IconData categoryIcon;

    // Determine icon and color based on category
    switch (expense.category) {
      case 'Bazaar':
        categoryColor = Colors.green;
        categoryIcon = Icons.shopping_cart;
        break;
      case 'Utility':
        categoryColor = Colors.blue;
        categoryIcon = Icons.bolt;
        break;
      case 'Electricity':
        categoryColor = Colors.yellow[700]!;
        categoryIcon = Icons.electric_bolt;
        break;
      case 'Internet':
        categoryColor = Colors.purple;
        categoryIcon = Icons.wifi;
        break;
      case 'Gas':
        categoryColor = Colors.orange;
        categoryIcon = Icons.local_fire_department;
        break;
      case 'Water':
        categoryColor = Colors.lightBlue;
        categoryIcon = Icons.water_drop;
        break;
      case 'Cleaning':
        categoryColor = Colors.teal;
        categoryIcon = Icons.cleaning_services;
        break;
      default:
        categoryColor = Colors.grey;
        categoryIcon = Icons.category;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Expense details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: AppStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(expense.date),
                          style: AppStyles.caption.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.person, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            expense.addedByName,
                            style: AppStyles.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Helpers.formatCurrency(expense.amount),
                    style: AppStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      expense.category,
                      style: AppStyles.caption.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
