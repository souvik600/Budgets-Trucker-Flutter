import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/models/meal_entry_model.dart';

class MealCard extends StatelessWidget {
  final MealEntryModel meal;
  final double mealRate;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.mealRate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalMeals = meal.breakfast + meal.lunch + meal.dinner;
    final totalCost = totalMeals * mealRate;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEE, MMM dd').format(meal.date),
                    style: AppStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total: $totalMeals meals',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMealItem(
                    label: 'Breakfast',
                    count: meal.breakfast,
                    icon: Icons.free_breakfast,
                    color: Colors.orange,
                  ),
                  _buildMealItem(
                    label: 'Lunch',
                    count: meal.lunch,
                    icon: Icons.lunch_dining,
                    color: Colors.green,
                  ),
                  _buildMealItem(
                    label: 'Dinner',
                    count: meal.dinner,
                    icon: Icons.dinner_dining,
                    color: Colors.blue,
                  ),
                ],
              ),
              if (meal.note != null && meal.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.note,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          meal.note!,
                          style: AppStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cost:',
                    style: AppStyles.bodyText2,
                  ),
                  Text(
                    '${NumberFormat.currency(symbol: '৳').format(totalCost)} (${NumberFormat.currency(symbol: '৳').format(mealRate)}/meal)',
                    style: AppStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
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

  Widget _buildMealItem({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.caption,
        ),
        const SizedBox(height: 2),
        Text(
          count.toString(),
          style: AppStyles.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}