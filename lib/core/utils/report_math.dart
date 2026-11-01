import 'package:inventory_pro/core/utils/sales_math.dart';

class ReportMath {
  static List<DateTime> lastNMonths(DateTime from, int n) {
    return List.generate(n, (i) => SalesMath.monthStart(from, monthsAgo: n - 1 - i));
  }

  static String monthLabel(DateTime d) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[d.month - 1];
  }
}