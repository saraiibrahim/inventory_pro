class SalesMath {
  // 🔧 لو مفيش بيانات شهر سابق للمقارنة، بترجع صفر بدل ما تكسر أو تدي رقم وهمي
  static double percentGrowth(double current, double previous) {
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  static DateTime monthStart(DateTime d, {int monthsAgo = 0}) {
    int month = d.month - monthsAgo;
    int year = d.year;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    return DateTime(year, month, 1);
  }
}
