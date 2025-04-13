import 'package:flutter/material.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/utils/helpers.dart';

class MealRateCard extends StatelessWidget {
  final double mealRate;

  const MealRateCard({
    super.key,
    required this.mealRate,
  });

  @override
  Widget build(BuildContext context) {
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
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.mealRate,
                  style: AppStyles.subtitle2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              Helpers.formatCurrency(mealRate),
              style: AppStyles.headline3,
            ),
            Text(
              'per meal',
              style: AppStyles.caption.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}