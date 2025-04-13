import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/services/auth_service.dart';
import 'package:mass_manager/core/utils/helpers.dart';
import 'package:mass_manager/core/utils/validators.dart';
import 'package:mass_manager/features/expenses/bloc/expense_bloc.dart';
import 'package:mass_manager/layout/custom_app_bar.dart';
import 'package:mass_manager/models/expense_model.dart';
import '../../../core/services/firestore_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId;

  const AddExpenseScreen({super.key, this.expenseId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Bazaar';
  DateTime _selectedDate = DateTime.now();

  ExpenseModel? _existingExpense;
  bool _isLoading = false;

  // List of expense categories
  final List<String> _categories = [
    'Bazaar',
    'Utility',
    'Electricity',
    'Internet',
    'Gas',
    'Water',
    'Cleaning',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _loadExpenseData();
    }
  }

  Future<void> _loadExpenseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenseDoc =
          await context
              .read<FirestoreService>()
              .expensesRef
              .doc(widget.expenseId)
              .get();

      if (expenseDoc.exists) {
        _existingExpense = ExpenseModel.fromMap(
          expenseDoc.data() as Map<String, dynamic>,
        );

        setState(() {
          _selectedCategory = _existingExpense!.category;
          _selectedDate = _existingExpense!.date;
          _amountController.text = _existingExpense!.amount.toString();
          _descriptionController.text = _existingExpense!.description;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading expense: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year - 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authService = context.read<AuthService>();
      final currentUser = await authService.getCurrentUserProfile();

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      if (_existingExpense != null) {
        // Update existing expense
        context.read<ExpenseBloc>().add(
          UpdateExpenseEvent(
            expense: _existingExpense!,
            category: _selectedCategory,
            amount: amount,
            date: _selectedDate,
            description: description,
          ),
        );
      } else {
        // Add new expense
        context.read<ExpenseBloc>().add(
          AddExpenseEvent(
            category: _selectedCategory,
            amount: amount,
            date: _selectedDate,
            description: description,
            addedBy: currentUser.id,
            addedByName: currentUser.name,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            _existingExpense != null ? 'Edit Expense' : AppStrings.addExpense,
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ExpenseErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category selector
                    Text(
                      'Category',
                      style: AppStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items:
                              _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date picker
                    Text(
                      'Date',
                      style: AppStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'EEEE, MMM dd, yyyy',
                              ).format(_selectedDate),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount input
                    Text(
                      'Amount',
                      style: AppStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validators.validateAmount,
                    ),
                    const SizedBox(height: 16),

                    // Description input
                    Text(
                      'Description',
                      style: AppStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter a brief description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state is ExpenseLoadingState ? null : _submitForm,
                        child:
                            state is ExpenseLoadingState
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _existingExpense != null
                                      ? 'Update Expense'
                                      : 'Add Expense',
                                ),
                      ),
                    ),

                    // Delete button (if editing)
                    if (_existingExpense != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                state is ExpenseLoadingState
                                    ? null
                                    : () {
                                      Helpers.showConfirmDialog(
                                        context,
                                        'Delete Expense',
                                        'Are you sure you want to delete this expense?',
                                      ).then((confirmed) {
                                        if (confirmed) {
                                          context.read<ExpenseBloc>().add(
                                            DeleteExpenseEvent(
                                              expenseId: _existingExpense!.id,
                                            ),
                                          );
                                        }
                                      });
                                    },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete Expense'),
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
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
