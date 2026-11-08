import 'package:flutter/material.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';
import 'package:inventory_pro/features/sales/transiction_sheet.dart';
import 'package:inventory_pro/widgets/status_badge.dart';

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
        ? primaryGreen.withValues(alpha: 0.08)
        : const Color(0xFF8E8E93).withValues(
            alpha: 0.08,
          ); // مصروفات المخازن برمز رمادي صامت وأنيق جداً

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
                      StatusBadge(status: transaction.status, compact: true),
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
                color: isIncome
                    ? mainTextColor
                    : textMuted.withValues(alpha: 0.8),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏷️ دالة مساعدة لإنشاء الـ Status Badge المطابقة لأعلى معايير الـ UX الهادئ والبريميوم
}
