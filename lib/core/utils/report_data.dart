import 'package:inventory_pro/core/utils/product_lookup.dart';
import 'package:inventory_pro/core/utils/report_math.dart';
import 'package:inventory_pro/core/utils/sales_math.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';

class ReportData {
  final int movementsLast7Days;
  final List<int> weeklyMovementCounts;
  final int maxWeekly;
  final double stockGrowth;
  final List<String> topCategories;
  final List<String> monthLabels;
  final List<List<double>> categorySeries;

  ReportData._({
    required this.movementsLast7Days,
    required this.weeklyMovementCounts,
    required this.maxWeekly,
    required this.stockGrowth,
    required this.topCategories,
    required this.monthLabels,
    required this.categorySeries,
  });

  factory ReportData.from(
    List<TransactionModel> transactions,
    List<ProductModel> products,
  ) {
    final now = DateTime.now();

    DateTime dateOf(TransactionModel t) =>
        DateTime.fromMillisecondsSinceEpoch(t.timestamp);

    // --- Stock Volatility ---
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final movementsLast7Days = transactions
        .where((t) => t.quantityChange != 0 && dateOf(t).isAfter(sevenDaysAgo))
        .length;

    final weeklyMovementCounts = List.generate(4, (i) {
      final weekStart = now.subtract(Duration(days: 7 * (4 - i)));
      final weekEnd = now.subtract(Duration(days: 7 * (3 - i)));
      return transactions.where((t) {
        final d = dateOf(t);
        return t.quantityChange != 0 &&
            !d.isBefore(weekStart) &&
            d.isBefore(weekEnd);
      }).length;
    });
    final maxWeekly = weeklyMovementCounts.fold<int>(
      1,
      (m, v) => v > m ? v : m,
    );

    // --- Stock Growth ---
    final currentTotalQty = products.fold<int>(0, (s, p) => s + p.quantity);
    final thisMonthStart = SalesMath.monthStart(now);
    final netChangeThisMonth = transactions
        .where((t) => !dateOf(t).isBefore(thisMonthStart))
        .fold<int>(0, (s, t) => s + t.quantityChange);
    final startOfMonthQty = currentTotalQty - netChangeThisMonth;
    final stockGrowth = startOfMonthQty == 0
        ? 0.0
        : (netChangeThisMonth / startOfMonthQty) * 100;

    // --- أكتر 3 فئات إيراداً ---
    final incomeTx = transactions.where((t) => t.isIncome).toList();
    String categoryOf(TransactionModel t) =>
        findProduct(products, t)?.category ?? 'Other';

    final Map<String, double> revenueByCategory = {};
    for (final t in incomeTx) {
      final c = categoryOf(t);
      revenueByCategory[c] = (revenueByCategory[c] ?? 0) + t.amount;
    }
    final sorted = revenueByCategory.keys.toList()
      ..sort((a, b) => revenueByCategory[b]!.compareTo(revenueByCategory[a]!));
    final topCategories = sorted.take(3).toList();

    final months = ReportMath.lastNMonths(now, 6);
    final categorySeries = topCategories.map((cat) {
      return months.map((m) {
        final mEnd = DateTime(m.year, m.month + 1, 1);
        return incomeTx
            .where((t) {
              final d = dateOf(t);
              return categoryOf(t) == cat && !d.isBefore(m) && d.isBefore(mEnd);
            })
            .fold<double>(0.0, (s, t) => s + t.amount);
      }).toList();
    }).toList();

    return ReportData._(
      movementsLast7Days: movementsLast7Days,
      weeklyMovementCounts: weeklyMovementCounts,
      maxWeekly: maxWeekly,
      stockGrowth: stockGrowth,
      topCategories: topCategories,
      monthLabels: months.map(ReportMath.monthLabel).toList(),
      categorySeries: categorySeries,
    );
  }
}
