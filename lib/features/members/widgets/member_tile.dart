import 'package:flutter/material.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/models/user_model.dart';

class MemberTile extends StatelessWidget {
  final UserModel member;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemberTile({
    super.key,
    required this.member,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar with role indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    member.name.isNotEmpty
                        ? member.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: AppStyles.headline3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (member.role == 'admin')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Member details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.email,
                    style: AppStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.phone,
                    style: AppStyles.caption,
                  ),
                ],
              ),
            ),

            // Actions
            if (isAdmin)
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Edit Member',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete,
                      color: AppColors.error,
                    ),
                    tooltip: 'Delete Member',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}