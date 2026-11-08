import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_pro/core/painters/report_painters.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/core/utils/report_data.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';
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

    final movementsLast7Days = data.movementsLast7Days;
    final weeklyMovementCounts = data.weeklyMovementCounts;
    final maxWeekly = data.maxWeekly;
    final stockGrowth = data.stockGrowth;
    final topCategories = data.topCategories;
    final monthLabels = data.monthLabels;
    final categorySeries = data.categorySeries;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // استخراج ألوان الـ AppTheme ديناميكياً لضمان توحيد الهوية البصرية 100%
    final Color scaffoldBg = theme
        .scaffoldBackgroundColor; // Sage Light في اللايت / Onyx Dark في الدارك
    final Color cardBg =
        theme.cardColor; // كروت بيضاء تماماً في اللايت / زمردي مطفي في الدارك
    final Color borderGlint =
        theme.colorScheme.outline; // خطوط تباين دقيقة وناعمة من الثيم

    final Color primaryGreen = theme
        .colorScheme
        .primary; // الأخضر الملكي في اللايت / النيون الساطع في الدارك
    final Color accentMint =
        theme.colorScheme.secondary; // التوهج الإضافي الهادئ للشارت والتأثيرات
    final Color textMuted =
        theme.textTheme.bodyMedium?.color ??
        Colors.grey; // رمادي مائل للميرمية للنصوص الثانوية
    final Color mainTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.white;
    final categoryColors = [
      primaryGreen,
      accentMint,
      isDark ? Colors.white70 : Colors.black45,
    ]; // أسود مخضر في اللايت / أبيض في الدارك

    // ظل خفيف مشتت لتثبيت الكروت على الأرضية الدافئة ومنع مشكلة "الحاجة طايرة" باللايت مود
    final List<BoxShadow> cardShadows = isDark
        ? []
        : [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.025),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.008),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚀 بتبدأ من فوق خالص (بدون AppBar) مع مسافة أمان للـ Notch
            const SizedBox(height: 35),

            // الـ Header الأنيق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Analytics &",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: mainTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Report",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: mainTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 📈 1. كارت الرسم البياني المتداخل الكبير (Detailed Revenue Breakdown)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: borderGlint),
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
                            "Detailed Revenue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: mainTextColor,
                            ),
                          ),
                          Text(
                            "Breakdown",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: mainTextColor,
                            ),
                          ),
                        ],
                      ),
                      // Indicators الرموز (BTC, XRP, SOL)
                      Row(
                        children: [
                          for (int i = 0; i < topCategories.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            _buildLegendItem(
                              "• ${topCategories[i]}",
                              categoryColors[i % categoryColors.length],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // لوحة الرسم المنحني المخصص بالـ Painter
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: categorySeries.isEmpty
                        ? Center(
                            child: Text(
                              "No sales data yet",
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                          )
                        : CustomPaint(
                            painter: CategoryRevenueChartPainter(
                              series: categorySeries,
                              colors: categoryColors,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // الأشهر تحت الجراف
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
            ),
            const SizedBox(height: 20),

            // 📊 2. صف الـ Widgets الجانبية المضيئة (Stock Volatility & Stock Growth)
            Row(
              children: [
                // كارت الـ Volatility بالأعمدة النيون الخضراء
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: 140,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderGlint),
                      boxShadow: cardShadows,
                    ),
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
                              "$movementsLast7Days",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: mainTextColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                            // ...
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(4, (i) {
                                final h = weeklyMovementCounts[i] == 0
                                    ? 4.0
                                    : (weeklyMovementCounts[i] / maxWeekly) *
                                          50;
                                return _buildMiniBar(h, i == 3, accentMint);
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // كارت الـ Stock Growth مع الجراف المملوء
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: 140,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderGlint),
                      boxShadow: cardShadows,
                    ),
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
                              // 🔧 جديد
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    // 🔧 جديد
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "${stockGrowth >= 0 ? '+' : ''}${stockGrowth.toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: mainTextColor,
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
                                      color: stockGrowth < 0
                                          ? AppTheme.alertRed
                                          : primaryGreen,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (stockGrowth < 0
                                                      ? AppTheme.alertRed
                                                      : primaryGreen)
                                                  .withValues(alpha: 0.4),
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
                              child: CustomPaint(
                                painter: MiniGrowthPainter(color: primaryGreen),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🧱 3. كروت الـ Deep Insights الأفقية العريضة الفخمة (زي صورتك بالظبط)
            Text(
              "Deep Insights",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: mainTextColor,
              ),
            ),
            const SizedBox(height: 12),
            if (topCategories.isNotEmpty)
              _buildHorizontalInsightCard(
                context,
                topCategories[0],
                "Top Category by Revenue", // 🔧 عدّلت النص كمان عشان يبقى صادق مع اللي بنحسبه فعلاً
                true,
                primaryGreen,
                accentMint,
                cardBg,
                borderGlint,
                mainTextColor,
                textMuted,
                cardShadows,
              ),
            if (topCategories.length > 1)
              _buildHorizontalInsightCard(
                context,
                topCategories[1],
                "2nd Category by Revenue", // 🔧
                false,
                primaryGreen,
                accentMint,
                cardBg,
                borderGlint,
                mainTextColor,
                textMuted,
                cardShadows,
              ),
            const SizedBox(
              height: 110,
            ), // مساحة الأمان عشان الـ Nav Bar المتألق
          ],
        ),
      ),
    );
  }

  // ويدجيت مساعدة لتكست الـ Crypto
  Widget _buildLegendItem(String label, Color color) {
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
    );
  }

  // بناء الأعمدة الصغيرة المضيئة
  Widget _buildMiniBar(double height, bool isGlowing, Color themeAccent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: isGlowing ? themeAccent : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // 👑 الويدجيت السحرية لكارت الـ Deep Insight العريض والأفقي
  Widget _buildHorizontalInsightCard(
    BuildContext context,
    String title,
    String subtitle,
    bool isFirst,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color borderGlint,
    Color mainTextColor,
    Color textMuted,
    List<BoxShadow> cardShadows,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 95,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGlint),
        boxShadow: cardShadows,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // النصوص على الشمال
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
                  color: mainTextColor,
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
          // جراف خطي مصغر وناعم جداً جوه الكارت على اليمين
          SizedBox(
            width: 120,
            height: 50,
            child: CustomPaint(
              painter: CurvedChartPainter(
                isDark: isDark,
                isMini: true,
                variant: isFirst,
                firstLineColor: primaryColor,
                secondLineColor: secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
