import 'dart:ui';
import 'package:inventory_pro/data/models/transaction_model.dart';

class StatusStyle {
  static String label(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.paid: return "Paid";
      case TransactionStatus.partial: return "Partial";
      case TransactionStatus.pending: return "Pending";
    }
  }

  static Color color(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.paid: return const Color(0xFF34C759);
      case TransactionStatus.partial: return const Color(0xFFFF9500);
      case TransactionStatus.pending: return const Color(0xFFFF453A);
    }
  }
}