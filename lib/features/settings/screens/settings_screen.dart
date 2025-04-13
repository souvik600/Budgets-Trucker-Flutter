import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/services/auth_service.dart';
import 'package:mass_manager/core/services/notification_service.dart';
import 'package:mass_manager/features/auth/bloc/auth_bloc.dart';
import 'package:mass_manager/layout/bottom_nav.dart';
import 'package:mass_manager/layout/custom_app_bar.dart';
import 'package:mass_manager/models/user_model.dart';
import 'package:mass_manager/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await context.read<AuthService>().getCurrentUserProfile();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);

    // Handle notifications
    final notificationService = NotificationService();
    if (_notificationsEnabled) {
      await notificationService.scheduleAllMealReminders();
    } else {
      await notificationService.cancelAllNotifications();
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveSettings();
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _saveSettings();
  }

  void _showEditProfileDialog() {
    if (_currentUser == null) return;

    final nameController = TextEditingController(text: _currentUser!.name);
    final phoneController = TextEditingController(text: _currentUser!.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: AppStyles.inputDecoration(
                  'Name',
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: AppStyles.inputDecoration(
                  'Phone',
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AuthService>().updateUserProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  _loadUserData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error updating profile: ${e.toString()}',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      phoneController.dispose();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(title: AppStrings.settings),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Profile Section
          Card(
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    CircleAvatar(
    radius: 40,
    backgroundColor: AppColors.primary.withOpacity(
    0.1,
    ),
    child: Text(
    _currentUser?.name.isNotEmpty == true
    ? _currentUser!.name
        .substring(0, 1)
        .toUpperCase()
        : '?',
    style: AppStyles.headline1.copyWith(
    color: AppColors.primary,
    ),
    ),
    ),
    const SizedBox(height: 16),
    Text(
    _currentUser?.name ?? 'User',
    style: AppStyles.headline3,
    ),
    Text(
    _currentUser?.email ?? '',
    style: AppStyles.bodyText2.copyWith(
    color: Colors.grey[600],
    ),
    ),
      const SizedBox(height: 8),
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
          _currentUser?.role == 'admin'
              ? 'Admin'
              : 'Member',
          style: AppStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _showEditProfileDialog,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profile'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ],
    ),
        ),
          ),

                const SizedBox(height: 24),

                // App Settings Section
                Text('App Settings', style: AppStyles.headline4),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Dark Mode
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Enable dark theme'),
                        secondary: const Icon(Icons.dark_mode),
                        value: _isDarkMode,
                        onChanged: _toggleDarkMode,
                        activeColor: AppColors.primary,
                      ),
                      const Divider(),

                      // Notifications
                      SwitchListTile(
                        title: const Text('Notifications'),
                        subtitle: const Text('Enable meal reminders'),
                        secondary: const Icon(Icons.notifications),
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Support Section
                Text('Support', style: AppStyles.headline4),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to help and support
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Show about dialog
                          showAboutDialog(
                            context: context,
                            applicationName: AppStrings.appName,
                            applicationVersion: '1.0.0',
                            applicationIcon: Image.asset(
                              'assets/images/logo.png',
                              width: 50,
                              height: 50,
                            ),
                            children: [
                              const Text(
                                'A meal management app for hostels, messes, and shared living spaces.',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
          ),
        ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }
}