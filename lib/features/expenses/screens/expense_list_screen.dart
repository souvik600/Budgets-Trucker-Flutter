import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/utils/helpers.dart';
import 'package:mass_manager/features/expenses/bloc/expense_bloc.dart';
import 'package:mass_manager/features/expenses/widgets/expense_list_item.dart';
import 'package:mass_manager/layout/bottom_nav.dart';
import 'package:mass_manager/layout/custom_app_bar.dart';
import 'package:mass_manager/routes/app_routes.dart';


class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedMonth;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
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
    _tabController = TabController(length: 2, vsync: this);
    _selectedMonth = DateTime.now();
    _loadExpenses();
  }

  void _loadExpenses() {
    if (_selectedCategory == 'All') {
      context.read<ExpenseBloc>().add(
        LoadExpensesEvent(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
      );
    } else {
      context.read<ExpenseBloc>().add(
        LoadExpensesByCategoryEvent(
          category: _selectedCategory,
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
      );
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(_selectedMonth.year - 1),
      lastDate: DateTime(_selectedMonth.year + 1),
      initialDatePickerMode: DatePickerMode.year,
      selectableDayPredicate: (DateTime date) {
        // Only allow selecting the first day of each month
        return date.day == 1;
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.expenses),
      body: Column(
        children: [
          // Month and Category Selectors
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Month selector
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectMonth(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(_selectedMonth),
                            style: AppStyles.subtitle2,
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Category selector
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
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
                          if (value != null && value != _selectedCategory) {
                            setState(() {
                              _selectedCategory = value;
                            });
                            _loadExpenses();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: 'List View'), Tab(text: 'Summary')],
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // List View Tab
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    if (state is ExpenseLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ExpensesLoadedState) {
                      if (state.expenses.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses found',
                                style: AppStyles.subtitle1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try selecting a different month or category',
                                style: AppStyles.bodyText2.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Total amount
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount:',
                                  style: AppStyles.subtitle1.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  Helpers.formatCurrency(state.totalAmount),
                                  style: AppStyles.headline3.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Expense list
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: state.expenses.length,
                              itemBuilder: (context, index) {
                                final expense = state.expenses[index];
                                return ExpenseListItem(
                                  expense: expense,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.addExpense,
                                      arguments: {'expenseId': expense.id},
                                    ).then((result) {
                                      if (result == true) {
                                        _loadExpenses();
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (state is ExpenseErrorState) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: AppStyles.bodyText1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadExpenses,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),

                // Summary Tab
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    if (state is ExpenseLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ExpensesLoadedState) {
                      // Group expenses by category
                      final Map<String, double> categoryTotals = {};
                      for (final expense in state.expenses) {
                        categoryTotals[expense.category] =
                            (categoryTotals[expense.category] ?? 0) +
                            expense.amount;
                      }

                      // Group expenses by date
                      final Map<DateTime, double> dateTotals = {};
                      for (final expense in state.expenses) {
                        final date = DateTime(
                          expense.date.year,
                          expense.date.month,
                          expense.date.day,
                        );
                        dateTotals[date] =
                            (dateTotals[date] ?? 0) + expense.amount;
                      }

                      if (state.expenses.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.insert_chart,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No data to display',
                                style: AppStyles.subtitle1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add some expenses to see the summary',
                                style: AppStyles.bodyText2.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total amount card
                            Card(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Spent',
                                      style: AppStyles.subtitle1,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      Helpers.formatCurrency(state.totalAmount),
                                      style: AppStyles.headline1.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'in ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                                      style: AppStyles.caption.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Category breakdown
                            Text(
                              'Expense by Category',
                              style: AppStyles.headline4,
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children:
                                  categoryTotals.entries.map((entry) {
                                    final percentage =
                                        (entry.value / state.totalAmount) * 100;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: AppStyles.subtitle2,
                                              ),
                                              Text(
                                                '${Helpers.formatCurrency(entry.value)} (${percentage.toStringAsFixed(1)}%)',
                                                style: AppStyles.subtitle2
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            value:
                                                entry.value / state.totalAmount,
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  _getCategoryColor(entry.key),
                                                ),
                                            minHeight: 10,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),

                            const SizedBox(height: 32),

                            // Daily expense chart
                            Text('Daily Expenses', style: AppStyles.headline4),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: dateTotals.length,
                                itemBuilder: (context, index) {
                                  final entry = dateTotals.entries.elementAt(
                                    index,
                                  );
                                  final date = entry.key;
                                  final amount = entry.value;
                                  final maxAmount = dateTotals.values.reduce(
                                    (a, b) => a > b ? a : b,
                                  );
                                  final barHeight = (amount / maxAmount) * 150;

                                  return Container(
                                    width: 60,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(
                                            Helpers.formatCurrency(amount),
                                            style: AppStyles.caption.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 150,
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: 30,
                                              height: barHeight,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            DateFormat('dd').format(date),
                                            style: AppStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense).then((result) {
            if (result == true) {
              _loadExpenses();
            }
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bazaar':
        return Colors.green;
      case 'Utility':
        return Colors.blue;
      case 'Electricity':
        return Colors.yellow[700]!;
      case 'Internet':
        return Colors.purple;
      case 'Gas':
        return Colors.orange;
      case 'Water':
        return Colors.lightBlue;
      case 'Cleaning':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
