import 'package:flutter/material.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/data/models/transaction_model.dart'; // 🔧 بدل import من sales_screen.dart

class TransactionDetailsSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsSheet({super.key, required this.transaction});

  // دالة ثابتة لفتح الـ BottomSheet بسهولة من أي مكان
  static void show(BuildContext context, TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color cardBg = theme.cardColor;
    final Color borderGlint = theme.colorScheme.outline;
    final Color primaryColor = theme.colorScheme.primary;
    final Color mainTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.white;
    final Color textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: borderGlint),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle العلوي
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // 🧾 هيدر الفاتورة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "INVOICE RECEIPT",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "TX-${transaction.id.toString().padLeft(3, '0')}", // 🔧 عشان id بقى int مش String زي "TX-101"
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: mainTextColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(transaction.status),
            ],
          ),
          const SizedBox(height: 24),

          // 💰 تفاصيل الملبغ والجهة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderGlint),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Entity / Client",
                      style: TextStyle(fontSize: 11, color: textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.entityName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: mainTextColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: transaction.isIncome
                        ? primaryColor
                        : AppTheme.alertRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 📝 عناصر الفاتورة والعمولات
          _buildDetailRow(
            "Date & Time",
            transaction.date,
            mainTextColor,
            textMuted,
          ),
          const Divider(height: 20, color: Colors.grey),
          _buildDetailRow(
            "Payment Method",
            "Apple Pay / Credit Card",
            mainTextColor,
            textMuted,
          ),
          const Divider(height: 20, color: Colors.grey),
          _buildDetailRow(
            "VAT / Tax (14%)",
            "\$${(transaction.amount * 0.14).toStringAsFixed(2)}",
            mainTextColor,
            textMuted,
          ),
          const Divider(height: 20, color: Colors.grey),
          _buildDetailRow(
            "Transaction Type",
            transaction.isIncome
                ? "Sales Order (Waerhouse In)"
                : "Restock Expense (Out)",
            mainTextColor,
            textMuted,
          ),
          const SizedBox(height: 28),

          // 🖨️ أزرار المشاركة والطباعة
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: borderGlint),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: mainTextColor,
                  ),
                  label: Text(
                    "Share PDF",
                    style: TextStyle(
                      color: mainTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text(
                    "Print Receipt",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color textColor,
    Color mutedColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: mutedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    String label;
    Color color;
    switch (status) {
      case TransactionStatus.paid:
        label = "Paid";
        color = const Color(0xFF34C759);
        break;
      case TransactionStatus.partial:
        label = "Partial";
        color = const Color(0xFFFF9500);
        break;
      case TransactionStatus.pending:
        label = "Pending";
        color = AppTheme.alertRed;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
