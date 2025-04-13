import 'package:flutter/material.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/utils/helpers.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final Color balanceColor = Helpers.getBalanceColor(balance);
    final String balanceText = balance >= 0
        ? Helpers.formatCurrency(balance)
        : '(${Helpers.formatCurrency(balance.abs())})';
    final String statusText = balance >= 0
        ? 'In Credit'
        : 'Due';

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
                    color: balanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    balance >= 0 ? Icons.account_balance : Icons.warning,
                    color: balanceColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.yourBalance,
                  style: AppStyles.subtitle2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              balanceText,
              style: AppStyles.headline3.copyWith(
                color: balanceColor,
              ),
            ),
            Text(
              statusText,
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