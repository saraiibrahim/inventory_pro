import 'package:flutter/material.dart';
import 'package:inventory_pro/core/painters/report_painters.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/core/theme/card_style.dart';

class RevenueBreakdownCard extends StatelessWidget {
  final List<String> categories;
  final List<List<double>> series;
  final List<String> monthLabels;

  const RevenueBreakdownCard({
    super.key,
    required this.categories,
    required this.series,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final mainText = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      isDark ? Colors.white70 : Colors.black45,
    ];
    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: mainText,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecorationOf(theme, radius: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Detailed Revenue", style: titleStyle),
                  Text("Breakdown", style: titleStyle),
                ],
              ),
              Row(
                children: [
                  for (int i = 0; i < categories.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Text(
                      "• ${categories[i]}",
                      style: TextStyle(
                        color: colors[i % colors.length],
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: series.isEmpty
                ? Center(
                    child: Text(
                      "No sales data yet",
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  )
                : CustomPaint(
                    painter: CategoryRevenueChartPainter(
                      series: series,
                      colors: colors,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthLabels
                .map(
                  (m) => Text(
                    m,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class StockVolatilityCard extends StatelessWidget {
  final int movements;
  final List<int> weeklyCounts;
  final int maxWeekly;

  const StockVolatilityCard({
    super.key,
    required this.movements,
    required this.weeklyCounts,
    required this.maxWeekly,
  });

  Widget _bar(double height, bool glowing, Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: glowing ? accent : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final mainText = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 140,
      decoration: cardDecorationOf(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stock Volatility",
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$movements",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: mainText,
                  fontFamily: 'monospace',
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(weeklyCounts.length, (i) {
                  final h = weeklyCounts[i] == 0
                      ? 4.0
                      : (weeklyCounts[i] / maxWeekly) * 50;
                  return _bar(
                    h,
                    i == weeklyCounts.length - 1,
                    theme.colorScheme.secondary,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StockGrowthCard extends StatelessWidget {
  final double growth;
  const StockGrowthCard({super.key, required this.growth});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final mainText = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final primary = theme.colorScheme.primary;
    final dotColor = growth < 0 ? AppTheme.alertRed : primary;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 140,
      decoration: cardDecorationOf(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stock Growth",
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: mainText,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 40,
                child: CustomPaint(painter: MiniGrowthPainter(color: primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isFirst;

  const InsightCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final mainText = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 95,
      decoration: cardDecorationOf(theme),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Deep Insights",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: mainText,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: textMuted.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 120,
            height: 50,
            child: CustomPaint(
              painter: CurvedChartPainter(
                isDark: isDark,
                isMini: true,
                variant: isFirst,
                firstLineColor: theme.colorScheme.primary,
                secondLineColor: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
