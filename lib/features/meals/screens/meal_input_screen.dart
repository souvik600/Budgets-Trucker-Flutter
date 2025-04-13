import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/services/auth_service.dart';
import 'package:mass_manager/core/utils/helpers.dart';
import 'package:mass_manager/features/meals/bloc/meal_bloc.dart';
import 'package:mass_manager/layout/custom_app_bar.dart';
import 'package:mass_manager/models/meal_entry_model.dart';
import '../../../core/services/firestore_service.dart';

class MealInputScreen extends StatefulWidget {
  final String? userId;
  final DateTime? date;

  const MealInputScreen({
    super.key,
    this.userId,
    this.date,
  });

  @override
  State<MealInputScreen> createState() => _MealInputScreenState();
}

class _MealInputScreenState extends State<MealInputScreen> {
  late DateTime _selectedDate;
  late String _userId;
  String _userName = '';
  bool _isAdmin = false;

  final _formKey = GlobalKey<FormState>();
  final _breakfastController = TextEditingController(text: '0');
  final _lunchController = TextEditingController(text: '0');
  final _dinnerController = TextEditingController(text: '0');
  final _noteController = TextEditingController();

  MealEntryModel? _existingMeal;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? DateTime.now();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = context.read<AuthService>();

    // Check if user is admin
    _isAdmin = await authService.isUserAdmin();

    // Set user ID (if provided or current user)
    if (widget.userId != null && _isAdmin) {
      _userId = widget.userId!;
      // Load user details
      final user = await context.read<FirestoreService>().getUserById(_userId);
      if (user != null) {
        setState(() {
          _userName = user.name;
        });
      }
    } else {
      final currentUser = await authService.getCurrentUserProfile();
      setState(() {
        _userId = currentUser.id;
        _userName = currentUser.name;
      });
    }

    // Load existing meal data
    _loadMealData();
  }

  Future<void> _loadMealData() async {
    // Load meals for the selected date
    final meals = await context.read<FirestoreService>().getMealsForDay(_selectedDate).first;

    // Find meal for the current user
    final existingMeal = meals.any((meal) => meal.userId == _userId)
        ? meals.firstWhere((meal) => meal.userId == _userId)
        : null;
    if (existingMeal != null) {
      setState(() {
        _existingMeal = existingMeal;
        _breakfastController.text = existingMeal.breakfast.toString();
        _lunchController.text = existingMeal.lunch.toString();
        _dinnerController.text = existingMeal.dinner.toString();
        _noteController.text = existingMeal.note ?? '';
      });
    } else {
      setState(() {
        _existingMeal = null;
        _breakfastController.text = '0';
        _lunchController.text = '0';
        _dinnerController.text = '0';
        _noteController.text = '';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year, _selectedDate.month - 1, 1),
      lastDate: DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMealData();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final breakfast = int.parse(_breakfastController.text);
      final lunch = int.parse(_lunchController.text);
      final dinner = int.parse(_dinnerController.text);
      final note = _noteController.text.trim();

      if (_existingMeal != null) {
        // Update existing meal
        context.read<MealBloc>().add(
          UpdateMealEntryEvent(
            meal: _existingMeal!,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            note: note.isNotEmpty ? note : null,
          ),
        );
      } else {
        // Add new meal
        context.read<MealBloc>().add(
          AddMealEntryEvent(
            userId: _userId,
            userName: _userName,
            date: _selectedDate,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            note: note.isNotEmpty ? note : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: _existingMeal != null ? AppStrings.updateMeal : AppStrings.addMeal,
        ),
        body: BlocConsumer<MealBloc, MealState>(
        listener: (context, state) {
      if (state is MealOperationSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else if (state is MealErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    },
    builder: (context, state) {
    return SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info (if admin)
          if (_isAdmin && _userName.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'User: $_userName',
                      style: AppStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Date selector
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                          style: AppStyles.subtitle1,
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Meal input form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Meal Count',
                  style: AppStyles.headline4,
                ),
                const SizedBox(height: 16),

                // Breakfast
                _buildMealInput(
                  title: AppStrings.breakfast,
                  controller: _breakfastController,
                  icon: Icons.free_breakfast,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                // Lunch
                _buildMealInput(
                  title: AppStrings.lunch,
                  controller: _lunchController,
                  icon: Icons.lunch_dining,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                // Dinner
                _buildMealInput(
                  title: AppStrings.dinner,
                  controller: _dinnerController,
                  icon: Icons.dinner_dining,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // Note
                Text(
                  'Note (Optional)',
                  style: AppStyles.subtitle1,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: AppStyles.inputDecoration(
                    'Add a note (e.g., guest, special meal)',
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is MealLoadingState ? null : _submitForm,
                    child: state is MealLoadingState
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      _existingMeal != null
                          ? AppStrings.updateMeal
                          : AppStrings.addMeal,
                    ),
                  ),
                ),

                // Delete button (if editing)
                if (_existingMeal != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: state is MealLoadingState
                            ? null
                            : () {
                          Helpers.showConfirmDialog(
                            context,
                            'Delete Meal Entry',
                            'Are you sure you want to delete this meal entry?',
                          ).then((confirmed) {
                            if (confirmed) {
                              context.read<MealBloc>().add(
                                DeleteMealEntryEvent(
                                  mealId: _existingMeal!.id,
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Entry'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
    },
        ),
    );
  }

  Widget _buildMealInput({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.subtitle1,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Please enter a valid number';
                  }
                  if (number < 0) {
                    return 'Value cannot be negative';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
