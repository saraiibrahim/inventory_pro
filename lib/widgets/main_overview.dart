import 'package:flutter/material.dart';
import 'package:inventory_pro/core/painters/sparkline_painter.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/widgets/bento_card.dart'; // استيراد الثيم الموحد

class MainOverviewCard extends StatelessWidget {
  final String totalSales;
  final double salesGrowth;
  final int totalProducts;
  final int lowStockItems;
  final int outOfStockItems;
  final List<double> sparklineData;

  const MainOverviewCard({
    super.key,
    required this.totalSales,
    required this.salesGrowth,
    required this.totalProducts,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // استخدام لون الـ primary والـ secondary من الثيم ديناميكياً لتناسق تام
    final Color mainTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.white;
    final Color textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ السطر العلوي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "OVERVIEW · TODAY",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : theme.colorScheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                ),
                child: Text(
                  "View metrics",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white70 : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2️⃣ الكارت الكبير مع الشارت
          BentoCard(
            height: 140,
            theme: theme,
            isDark: isDark,
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      top: 16.0,
                      bottom: 16.0,
                      right: 4.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Net Revenue",
                          style: TextStyle(
                            fontSize: 12,
                            color: textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                totalSales,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: mainTextColor,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${salesGrowth >= 0 ? '+' : ''}${salesGrowth.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.neonGreen
                                      : AppTheme.deepGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 28.0,
                      right: 16.0,
                      bottom: 8.0,
                    ),
                    child: SizedBox(
                      height: double.infinity,
                      child: CustomPaint(
                        painter: SparklinePainter(
                          dataPoints: sparklineData,
                          color: AppTheme.neonGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3️⃣ الـ Bento Grid التلاتية الأحادية المتناسقة مع الشارت
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  height: 90,
                  theme: theme,
                  isDark: isDark,
                  child: _buildCleanMiniStat(
                    label: "Products",
                    value: "$totalProducts",
                    theme: theme,
                    indicatorColor: isDark
                        ? AppTheme.neonGreen
                        : AppTheme.deepGreen, // أخضر ميرمية راقي للـ Products
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BentoCard(
                  height: 90,
                  theme: theme,
                  isDark: isDark,
                  child: _buildCleanMiniStat(
                    label: "Low Stock",
                    value: "$lowStockItems",
                    theme: theme,
                    indicatorColor: lowStockItems == 0
                        ? Colors.grey.withValues(alpha: 0.4)
                        : const Color.fromARGB(
                            255,
                            240,
                            180,
                            96,
                          ), // برتقالي هادئ للـ Low Stock
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BentoCard(
                  height: 90,
                  theme: theme,
                  isDark: isDark,
                  child: _buildCleanMiniStat(
                    label: "Out Stock",
                    value: "$outOfStockItems",
                    theme: theme,
                    indicatorColor: outOfStockItems == 0
                        ? Colors.grey.withValues(alpha: 0.4)
                        : AppTheme.alertRed, // الأحمر الدافئ للـ Out of stock
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCleanMiniStat({
    required String label,
    required String value,
    required ThemeData theme,
    required Color indicatorColor,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: indicatorColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : theme.textTheme.bodyLarge?.color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
