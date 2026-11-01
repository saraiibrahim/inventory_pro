import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/core/theme/theme_manager.dart';
import 'package:inventory_pro/data/repositories/product_repository.dart';
import 'package:inventory_pro/logic/cubits/product_cubit.dart';
import 'package:inventory_pro/features/dashboard/dashboard_screen.dart';
import 'package:inventory_pro/data/repositories/transaction_repository.dart';
import 'package:inventory_pro/logic/cubits/transaction_cubit.dart'; // 🔧

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ProductCubit(ProductRepository())..loadProducts(),
        ),
        BlocProvider(
          create: (context) =>
              TransactionCubit(TransactionRepository())..loadTransactions(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.themeModeNotifier,
        builder: (context, currentThemeMode, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentThemeMode,

            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
