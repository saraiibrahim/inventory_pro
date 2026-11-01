import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🔧
import 'package:inventory_pro/data/models/transaction_model.dart'; // 🔧
import 'package:inventory_pro/logic/cubits/transaction_cubit.dart'; // 🔧
import 'package:inventory_pro/features/sales/transiction_sheet.dart';
import 'package:inventory_pro/core/utils/sales_math.dart'; // 🔧

// 🔧 كلاس SalesTransaction و TransactionStatus اتشالوا من هنا، دلوقتي في data/models/transaction_model.dart

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

bool _showAll = false; // 🔧

class _SalesScreenState extends State<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color scaffoldBg = theme.scaffoldBackgroundColor;
    final Color cardBg = theme.cardColor;
    final Color borderGlint = theme.colorScheme.outline;
    final Color primaryGreen = theme.colorScheme.primary;
    final Color textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final Color mainTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.white;

    final List<BoxShadow> cardShadows = isDark
        ? []
        : [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.03),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 0,
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        // 🔧
        builder: (context, state) {
          final transactions = state is TransactionLoaded
              ? state.transactions
              : <TransactionModel>[];

          final incomeTx = transactions.where((t) => t.isIncome).toList();

          final totalRevenue = incomeTx.fold<double>(
            0.0,
            (sum, t) => sum + t.amount,
          );
          final incomeCount = incomeTx.length;
          final avgOrder = incomeCount == 0 ? 0.0 : totalRevenue / incomeCount;

          // حساب النمو: الشهر الحالي مقابل اللي قبله
          final now = DateTime.now();
          final thisMonthStart = SalesMath.monthStart(now);
          final lastMonthStart = SalesMath.monthStart(now, monthsAgo: 1);

          final thisMonthTx = incomeTx.where(
            (t) => !DateTime.fromMillisecondsSinceEpoch(
              t.timestamp,
            ).isBefore(thisMonthStart),
          );
          final lastMonthTx = incomeTx.where((t) {
            final d = DateTime.fromMillisecondsSinceEpoch(t.timestamp);
            return !d.isBefore(lastMonthStart) && d.isBefore(thisMonthStart);
          });

          final thisMonthTotal = thisMonthTx.fold<double>(
            0.0,
            (s, t) => s + t.amount,
          );
          final lastMonthTotal = lastMonthTx.fold<double>(
            0.0,
            (s, t) => s + t.amount,
          );
          final revenueGrowth = SalesMath.percentGrowth(
            thisMonthTotal,
            lastMonthTotal,
          );

          final thisMonthAvg = thisMonthTx.isEmpty
              ? 0.0
              : thisMonthTotal / thisMonthTx.length;
          final lastMonthAvg = lastMonthTx.isEmpty
              ? 0.0
              : lastMonthTotal / lastMonthTx.length;
          final avgGrowth = SalesMath.percentGrowth(
            thisMonthAvg,
            lastMonthAvg,
          ); // 🔧
          final visible = _showAll
              ? transactions
              : transactions.take(5).toList(); // 🔧

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          "Sales",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: mainTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Executive Overview",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderGlint),
                        boxShadow: cardShadows,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Jun 2026",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: mainTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderGlint),
                          boxShadow: cardShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1D2222)
                                    : primaryGreen.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 18,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "\$${totalRevenue.toStringAsFixed(1)}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: mainTextColor,
                              ),
                            ), // 🔧 كانت $842.5k ثابتة
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "Total Revenue",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryGreen.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "${revenueGrowth >= 0 ? '+' : ''}${revenueGrowth.toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderGlint),
                          boxShadow: cardShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1D2222)
                                    : primaryGreen.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.show_chart_rounded,
                                size: 18,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "\$${avgOrder.toStringAsFixed(1)}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: mainTextColor,
                              ),
                            ), // 🔧 كانت $1.2k ثابتة
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "Avg. Order",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryGreen.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "${avgGrowth >= 0 ? '+' : ''}${avgGrowth.toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: primaryGreen,
                                    ),
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
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: mainTextColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showAll = !_showAll), // 🔧
                      child: Text(
                        _showAll ? "Show Less" : "See All", // 🔧
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                transactions
                        .isEmpty // 🔧 حالة فاضية بدل ما نفترض فيه بيانات دايماً
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "No transactions yet",
                            style: TextStyle(color: textMuted),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visible.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = visible[index];
                          return PremiumTransactionRow(
                            transaction: tx,
                            cardBg: cardBg,
                            borderGlint: borderGlint,
                            textMuted: textMuted,
                            primaryGreen: primaryGreen,
                            mainTextColor: mainTextColor,
                            cardShadows: cardShadows,
                          );
                        },
                      ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🧱 ويدجيت الصف الفردي للمعاملة المالية - ثابت، غير طائر، ومبني بأرقى الألوان الهادئة
class PremiumTransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final Color cardBg;
  final Color borderGlint;
  final Color textMuted;
  final Color primaryGreen;
  final Color mainTextColor;
  final List<BoxShadow> cardShadows;

  const PremiumTransactionRow({
    super.key,
    required this.transaction,
    required this.cardBg,
    required this.borderGlint,
    required this.textMuted,
    required this.primaryGreen,
    required this.mainTextColor,
    required this.cardShadows,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;

    // ألوان هادئة جداً للفصل والتمييز بدون صخب (سهم صاعد مطفي للوارد، هابط صامت وداكن للصادر)
    final Color flowIconBg = isIncome
        ? primaryGreen.withOpacity(0.08)
        : const Color(
            0xFF8E8E93,
          ).withOpacity(0.08); // مصروفات المخازن برمز رمادي صامت وأنيق جداً

    final Color flowIconColor = isIncome
        ? primaryGreen
        : const Color(0xFF8E8E93);

    return InkWell(
      onTap: () {
        // فتح الـ BottomSheet لعرض تفاصيل المعاملة المالية
        TransactionDetailsSheet.show(context, transaction);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderGlint),
          boxShadow: cardShadows,
        ),
        child: Row(
          children: [
            // 🏹 أيقونة اتجاه التدفق المالي (وارد / صادر)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: flowIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
                color: flowIconColor,
              ),
            ),
            const SizedBox(width: 14),

            // ℹ️ تفاصيل المعاملة والـ Status Badge الدقيقة والذكية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.entityName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: mainTextColor,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        transaction.date,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 🏷️ الـ Status Badge الدقيقة
                      _buildStatusChip(transaction.status),
                    ],
                  ),
                ],
              ),
            ),

            // 💰 القيمة المالية بنظام الأرقام الموحد مع تهريب علامة الـ $ لمنع التعارض في Dart compiler
            Text(
              "${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: isIncome ? mainTextColor : textMuted.withOpacity(0.8),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏷️ دالة مساعدة لإنشاء الـ Status Badge المطابقة لأعلى معايير الـ UX الهادئ والبريميوم
  Widget _buildStatusChip(TransactionStatus status) {
    String label;
    Color color;

    switch (status) {
      case TransactionStatus.paid:
        label = "Paid";
        color = const Color(0xFF34C759); // أخضر هادئ
        break;
      case TransactionStatus.partial:
        label = "Partial";
        color = const Color(0xFFFF9500); // برتقالي هادئ جداً للمستحقات الجزئية
        break;
      case TransactionStatus.pending:
        label = "Pending";
        color = const Color(0xFFFF453A); // أحمر دافئ للمتأخرات
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
