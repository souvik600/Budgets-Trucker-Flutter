import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/services/auth_service.dart';
import 'package:mass_manager/core/services/firestore_service.dart';
import 'package:mass_manager/core/utils/helpers.dart';
import 'package:mass_manager/features/home/bloc/home_bloc.dart';
import 'package:mass_manager/features/home/widgets/balance_card.dart';
import 'package:mass_manager/features/home/widgets/meal_rate_card.dart';
import 'package:mass_manager/features/home/widgets/summary_card.dart';
import 'package:mass_manager/features/home/widgets/todays_meal_card.dart';
import 'package:mass_manager/layout/bottom_nav.dart';
import 'package:mass_manager/layout/custom_app_bar.dart';
import 'package:mass_manager/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _now = DateTime.now();
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(
      authService: context.read<AuthService>(),
      firestoreService: context.read<FirestoreService>(),
    );
    _loadData();
  }

  void _loadData() {
    _homeBloc.add(LoadHomeDataEvent(
      year: _now.year,
      month: _now.month,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppStrings.dashboard,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is HomeLoadedState) {
              return RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.welcome}, ${state.currentUser.name}!',
                          style: AppStyles.headline3,
                        ),
                        Text(
                          Helpers.getCurrentMonthYear(),
                          style: AppStyles.subtitle2.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: MealRateCard(
                                mealRate: state.mealRate,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: BalanceCard(
                                balance: state.balance,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Today's Meals
                        TodaysMealCard(
                          meals: state.todayMeals,
                          onAddMeal: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.mealInput,
                              arguments: {
                                'userId': state.currentUser.id,
                                'date': DateTime.now(),
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Expense Summary
                        SummaryCard(
                          title: AppStrings.totalExpenses,
                          value: Helpers.formatCurrency(state.totalExpenses),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.info,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.expenseList,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Add Expense Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addExpense,
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text(AppStrings.addExpense),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Category Stats
                        if (state.categoryStats.isNotEmpty) ...[
                          Text(
                            'Expense Breakdown',
                            style: AppStyles.headline4,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.categoryStats.length,
                              itemBuilder: (context, index) {
                                final category = state.categoryStats.keys.elementAt(index);
                                final amount = state.categoryStats[category] ?? 0;
                                return _buildCategoryCard(category, amount);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is HomeErrorState) {
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
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        bottomNavigationBar: const BottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildCategoryCard(String category, double amount) {
    Color cardColor;
    IconData iconData;

    switch (category) {
      case 'Bazaar':
        cardColor = Colors.green[100]!;
        iconData = Icons.shopping_cart;
        break;
      case 'Utility':
        cardColor = Colors.blue[100]!;
        iconData = Icons.bolt;
        break;
      case 'Internet':
        cardColor = Colors.purple[100]!;
        iconData = Icons.wifi;
        break;
      case 'Gas':
        cardColor = Colors.orange[100]!;
        iconData = Icons.local_fire_department;
        break;
      case 'Water':
        cardColor = Colors.lightBlue[100]!;
        iconData = Icons.water_drop;
        break;
      case 'Cleaning':
        cardColor = Colors.teal[100]!;
        iconData = Icons.cleaning_services;
        break;
      default:
        cardColor = Colors.grey[100]!;
        iconData = Icons.category;
    }

    return Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          iconData,
          color: Colors.black54,
          size: 32,
        ),
        const Spacer(),
        Text(
          category,
          style: AppStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Helpers.formatCurrency(amount),
          style: AppStyles.headline4,
        ),
      ],
    ),
        ),
    );
  }
}