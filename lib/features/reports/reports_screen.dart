import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_pro/core/utils/report_data.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';
import 'package:inventory_pro/features/reports/widgets/report_cards.dart';
import 'package:inventory_pro/logic/cubits/product_cubit.dart';
import 'package:inventory_pro/logic/cubits/transaction_cubit.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txState = context.watch<TransactionCubit>().state;
    final transactions = txState is TransactionLoaded
        ? txState.transactions
        : <TransactionModel>[];

    final prodState = context.watch<ProductCubit>().state;
    final products = prodState is ProductLoaded
        ? prodState.products
        : <ProductModel>[];

    final data = ReportData.from(transactions, products);
    final theme = Theme.of(context);
    final mainText = theme.textTheme.bodyLarge?.color;
    final titleStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: mainText,
      letterSpacing: -0.5,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            Text("Analytics &", style: titleStyle),
            Text("Report", style: titleStyle),
            const SizedBox(height: 24),
            RevenueBreakdownCard(
              categories: data.topCategories,
              series: data.categorySeries,
              monthLabels: data.monthLabels,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StockVolatilityCard(
                    movements: data.movementsLast7Days,
                    weeklyCounts: data.weeklyMovementCounts,
                    maxWeekly: data.maxWeekly,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: StockGrowthCard(growth: data.stockGrowth)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Deep Insights",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: mainText,
              ),
            ),
            const SizedBox(height: 12),
            if (data.topCategories.isNotEmpty)
              InsightCard(
                title: data.topCategories[0],
                subtitle: "Top Category by Revenue",
                isFirst: true,
              ),
            if (data.topCategories.length > 1)
              InsightCard(
                title: data.topCategories[1],
                subtitle: "2nd Category by Revenue",
                isFirst: false,
              ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
