import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_pro/core/theme/theme_manager.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/logic/cubits/product_cubit.dart';
import 'package:inventory_pro/widgets/custom_bento_nav_bar.dart';
import 'package:inventory_pro/widgets/main_overview.dart';
import 'package:inventory_pro/core/utils/sales_math.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';
import 'package:inventory_pro/logic/cubits/transaction_cubit.dart';
import 'package:inventory_pro/widgets/top_saless.dart';

import '../products/products_screen.dart';
import '../sales/sales_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  Widget _buildHomeScreen(BuildContext context, List<ProductModel> products) {
    final lowStock = products
        .where((p) => p.quantity > 0 && p.quantity < 10)
        .length;
    final outOfStock = products.where((p) => p.quantity == 0).length;

    final txState = context.watch<TransactionCubit>().state;
    final transactions = txState is TransactionLoaded
        ? txState.transactions
        : <TransactionModel>[];
    final incomeTx = transactions.where((t) => t.isIncome).toList();

    final totalRevenue = incomeTx.fold<double>(0.0, (s, t) => s + t.amount);

    final now = DateTime.now();
    final thisMonthStart = SalesMath.monthStart(now);
    final lastMonthStart = SalesMath.monthStart(now, monthsAgo: 1);
    final thisMonthTotal = incomeTx
        .where(
          (t) => !DateTime.fromMillisecondsSinceEpoch(
            t.timestamp,
          ).isBefore(thisMonthStart),
        )
        .fold<double>(0.0, (s, t) => s + t.amount);
    final lastMonthTotal = incomeTx
        .where((t) {
          final d = DateTime.fromMillisecondsSinceEpoch(t.timestamp);
          return !d.isBefore(lastMonthStart) && d.isBefore(thisMonthStart);
        })
        .fold<double>(0.0, (s, t) => s + t.amount);
    final growth = SalesMath.percentGrowth(thisMonthTotal, lastMonthTotal);

    final last7Days = List.generate(
      7,
      (i) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i)),
    );
    final sparkline = last7Days.map((day) {
      return incomeTx
          .where((t) {
            final d = DateTime.fromMillisecondsSinceEpoch(t.timestamp);
            return d.year == day.year &&
                d.month == day.month &&
                d.day == day.day;
          })
          .fold<double>(0.0, (s, t) => s + t.amount);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainOverviewCard(
            totalSales: "\$${totalRevenue.toStringAsFixed(1)}",
            salesGrowth: growth,
            totalProducts: products.length,
            lowStockItems: lowStock,
            outOfStockItems: outOfStock,
            sparklineData: sparkline,
          ),
          const SizedBox(height: 10),
          const TopSalesWidget(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: currentIndex == 0
          ? AppBar(
              title: Text(
                "Inventory Pro",
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: ThemeManager.toggleTheme,
                ),
              ],
            )
          : null,
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading || state is ProductInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }

          final products = state is ProductLoaded
              ? state.products
              : <ProductModel>[];

          final screens = [
            _buildHomeScreen(context, products),
            ProductsScreen(products: products),
            const SalesScreen(),
            const ReportsScreen(),
          ];

          return IndexedStack(index: currentIndex, children: screens);
        },
      ),
      bottomNavigationBar: CustomBentoNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
