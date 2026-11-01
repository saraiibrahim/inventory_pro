import 'package:flutter/material.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/data/models/transaction_model.dart';

class StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  final bool compact; // true = الشكل الصغير بتاع قايمة المعاملات

  const StatusBadge({super.key, required this.status, this.compact = false});

  String get _label {
    switch (status) {
      case TransactionStatus.paid:
        return "Paid";
      case TransactionStatus.partial:
        return "Partial";
      case TransactionStatus.pending:
        return "Pending";
    }
  }

  Color get _color {
    switch (status) {
      case TransactionStatus.paid:
        return const Color(0xFF34C759);
      case TransactionStatus.partial:
        return const Color(0xFFFF9500);
      case TransactionStatus.pending:
        return AppTheme.alertRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: compact ? 0.08 : 0.1),
        borderRadius: BorderRadius.circular(compact ? 6 : 10),
        border: Border.all(
          color: _color.withValues(alpha: compact ? 0.15 : 0.3),
          width: compact ? 0.5 : 1,
        ),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: compact ? 9 : 11,
          fontWeight: compact ? FontWeight.w800 : FontWeight.w900,
          color: _color,
        ),
      ),
    );
  }
}
