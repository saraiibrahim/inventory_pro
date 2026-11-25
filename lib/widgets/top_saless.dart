import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/core/utils/compact_number.dart';
import 'package:inventory_pro/core/utils/product_lookup.dart';
import 'package:inventory_pro/core/utils/sales_math.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';
import 'package:inventory_pro/logic/cubits/product_cubit.dart';
import 'package:inventory_pro/logic/cubits/transaction_cubit.dart';

class TopSalesWidget extends StatelessWidget {
  const TopSalesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<TransactionCubit, TransactionState>(
      // 🔧
      builder: (context, txState) {
        final transactions = txState is TransactionLoaded
            ? txState.transactions
            : <TransactionModel>[];
        final productState = context.watch<ProductCubit>().state; // 🔧
        final products = productState is ProductLoaded
            ? productState.products
            : <ProductModel>[];

        final topProducts = _computeTopProducts(transactions, products);

        final List<BoxShadow> cardShadows = isDark
            ? []
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.03),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
              boxShadow: cardShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TOP SELLING PRODUCTS",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.6,
                                  ),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                    Icon(
                      Icons.electric_bolt_rounded,
                      size: 18,
                      color: isDark ? AppTheme.neonGreen : AppTheme.deepGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                topProducts
                        .isEmpty // 🔧 حالة فاضية بدل الافتراض إن فيه بيانات دايماً
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "No sales yet",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white38
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topProducts.length,
                        separatorBuilder: (context, index) => Divider(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                          height: 20,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final p = topProducts[index];
                          final isNegative = p.growth < 0;

                          return Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : Colors.black.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "#${index + 1}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${p.category} · ${p.unitsSold} units",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white38
                                            : theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "\$${compactNumber(p.revenue)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${p.growth >= 0 ? '+' : ''}${p.growth.toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isNegative
                                          ? AppTheme.alertRed
                                          : (isDark
                                                ? AppTheme.neonGreen
                                                : AppTheme.deepGreen),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔧 تجميع مبيعات كل منتج من المعاملات الحقيقية + نسبة نموه الشهرية
  List<_TopProductStat> _computeTopProducts(
    List<TransactionModel> transactions,
    List<ProductModel> products,
  ) {
    final incomeTx = transactions.where((t) => t.isIncome).toList();
    if (incomeTx.isEmpty) return [];

    final now = DateTime.now();
    final thisMonthStart = SalesMath.monthStart(now);
    final lastMonthStart = SalesMath.monthStart(now, monthsAgo: 1);

    final Map<String, List<TransactionModel>> groups = {};
    for (final t in incomeTx) {
      final key = t.productId != 0 ? 'id${t.productId}' : t.entityName;
      groups.putIfAbsent(key, () => []).add(t);
    }

    final stats = groups.values.map((txs) {
      final product = findProduct(products, txs.first); // 🔧
      final name = product?.name ?? txs.first.entityName;
      final category = product?.category ?? "General";
      final totalRevenue = txs.fold<double>(0.0, (s, t) => s + t.amount);

      final units = txs.fold<int>(0, (s, t) => s - t.quantityChange);

      final thisMonthRevenue = txs
          .where(
            (t) => !DateTime.fromMillisecondsSinceEpoch(
              t.timestamp,
            ).isBefore(thisMonthStart),
          )
          .fold<double>(0.0, (s, t) => s + t.amount);
      final lastMonthRevenue = txs
          .where((t) {
            final d = DateTime.fromMillisecondsSinceEpoch(t.timestamp);
            return !d.isBefore(lastMonthStart) && d.isBefore(thisMonthStart);
          })
          .fold<double>(0.0, (s, t) => s + t.amount);

      return _TopProductStat(
        name: name,
        category: category,
        unitsSold: units > 0 ? units : txs.length,
        revenue: totalRevenue,
        growth: SalesMath.percentGrowth(thisMonthRevenue, lastMonthRevenue),
      );
    }).toList();

    stats.sort((a, b) => b.revenue.compareTo(a.revenue));
    return stats.take(3).toList();
  }
}

class _TopProductStat {
  final String name;
  final String category;
  final int unitsSold;
  final double revenue;
  final double growth;

  _TopProductStat({
    required this.name,
    required this.category,
    required this.unitsSold,
    required this.revenue,
    required this.growth,
  });
}
