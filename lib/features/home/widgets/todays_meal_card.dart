import 'package:flutter/material.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/models/meal_entry_model.dart';

class TodaysMealCard extends StatelessWidget {
  final List<MealEntryModel> meals;
  final VoidCallback onAddMeal;

  const TodaysMealCard({
    super.key,
    required this.meals,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    // Find current user's meal
    final String userId = ''; // TODO: Get current user ID
    final MealEntryModel? userMeal = meals.isEmpty
        ? null
        : meals.firstWhere(
          (meal) => meal.userId == userId,
      orElse: () => MealEntryModel(
        id: '',
        userId: '',
        userName: '',
        date: DateTime.now(),
        breakfast: 0,
        lunch: 0,
        dinner: 0,
        createdAt: DateTime.now(),
      ),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.todaysMeals,
                  style: AppStyles.headline4,
                ),
                ElevatedButton.icon(
                  onPressed: onAddMeal,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add/Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (userMeal == null || userMeal.id.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No meal entries for today yet',
                    style: AppStyles.bodyText1,
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMealItem(
                    'Breakfast',
                    userMeal.breakfast,
                    Icons.free_breakfast,
                    Colors.orange,
                  ),
                  _buildMealItem(
                    'Lunch',
                    userMeal.lunch,
                    Icons.lunch_dining,
                    Colors.green,
                  ),
                  _buildMealItem(
                    'Dinner',
                    userMeal.dinner,
                    Icons.dinner_dining,
                    Colors.blue,
                  ),
                ],
              ),
            if (userMeal != null && userMeal.id.isNotEmpty && userMeal.note != null && userMeal.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  width: double.infinity,
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
                          userMeal.note!,
                          style: AppStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(String title, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: AppStyles.headline4,
        ),
      ],
    );
  }
}