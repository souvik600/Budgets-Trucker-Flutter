import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/services/auth_service.dart';
import 'package:mass_manager/core/services/firestore_service.dart';
import 'package:mass_manager/core/services/notification_service.dart';
import 'package:mass_manager/features/auth/bloc/auth_bloc.dart';
import 'package:mass_manager/features/expenses/bloc/expense_bloc.dart';
import 'package:mass_manager/features/meals/bloc/meal_bloc.dart';
import 'package:mass_manager/features/members/bloc/member_bloc.dart';
import 'package:mass_manager/routes/app_routes.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create:
                (context) =>
                    AuthBloc(authService: context.read<AuthService>())
                      ..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<MealBloc>(
            create:
                (context) => MealBloc(
                  firestoreService: context.read<FirestoreService>(),
                ),
          ),
          BlocProvider<ExpenseBloc>(
            create:
                (context) => ExpenseBloc(
                  firestoreService: context.read<FirestoreService>(),
                ),
          ),
          BlocProvider<MemberBloc>(
            create:
                (context) => MemberBloc(
                  firestoreService: context.read<FirestoreService>(),
                  authService: context.read<AuthService>(),
                ),
          ),
        ],
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            return MaterialApp(
              title: 'Mass Manager',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: AppColors.primary,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  brightness: Brightness.light,
                ),
                fontFamily: 'Poppins',
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  color: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                primaryColor: AppColors.primaryDark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryDark,
                  brightness: Brightness.dark,
                ),
                fontFamily: 'Poppins',
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardTheme: CardTheme(
                  elevation: 2,
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              themeMode: ThemeMode.system,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
