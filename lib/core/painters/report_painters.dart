import 'package:flutter/material.dart';

class CategoryRevenueChartPainter extends CustomPainter {
  final List<List<double>> series; // كل عنصر = بيانات فئة واحدة (6 قيم شهرية)
  final List<Color> colors;

  CategoryRevenueChartPainter({required this.series, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || series.first.length < 2) return;

    final allValues = series.expand((s) => s).toList();
    double maxV = allValues.reduce((a, b) => a > b ? a : b);
    double minV = allValues.reduce((a, b) => a < b ? a : b);
    if (maxV == minV) maxV = minV + 1;

    for (int s = 0; s < series.length; s++) {
      final data = series[s];
      final color = colors[s % colors.length];
      final path = Path();
      final stepX = size.width / (data.length - 1);

      List<Offset> points = [];
      for (int i = 0; i < data.length; i++) {
        final x = i * stepX;
        final norm = (data[i] - minV) / (maxV - minV);
        final y =
            size.height - (norm * size.height * 0.85) - (size.height * 0.075);
        points.add(Offset(x, y));
      }

      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final c1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final c2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p1.dx, p1.dy);
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CategoryRevenueChartPainter oldDelegate) {
    return oldDelegate.series != series || oldDelegate.colors != colors;
  }
}

// 🎨 الرسام السحري لرسم الخطوط المتداخلة والمنحنية (Curved & Smooth Lines)
class CurvedChartPainter extends CustomPainter {
  final bool isDark;
  final bool isMini;
  final bool variant;
  final Color firstLineColor;
  final Color secondLineColor;

  CurvedChartPainter({
    required this.isDark,
    required this.firstLineColor,
    required this.secondLineColor,
    this.isMini = false,
    this.variant = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم الخط الأول
    var paint1 = Paint()
      ..color = isMini
          ? (variant ? secondLineColor : firstLineColor)
          : firstLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMini ? 2.0 : 3.0;

    // رسم الخط الثاني
    var paint2 = Paint()
      ..color = isMini ? Colors.grey.withValues(alpha: 0.15) : secondLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMini ? 1.5 : 2.5;

    var path1 = Path();
    var path2 = Path();

    if (!isMini) {
      // إحداثيات مدروسة ومطابقة للصورة الأساسية المتداخلة
      path1.moveTo(0, size.height * 0.5);
      path1.cubicTo(
        size.width * 0.2,
        size.height * 0.2,
        size.width * 0.3,
        size.height * 0.8,
        size.width * 0.5,
        size.height * 0.4,
      );
      path1.cubicTo(
        size.width * 0.7,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.9,
        size.width,
        size.height * 0.2,
      );

      path2.moveTo(0, size.height * 0.7);
      path2.cubicTo(
        size.width * 0.25,
        size.height * 0.9,
        size.width * 0.4,
        size.height * 0.1,
        size.width * 0.6,
        size.height * 0.6,
      );
      path2.cubicTo(
        size.width * 0.75,
        size.height * 0.9,
        size.width * 0.85,
        size.height * 0.2,
        size.width,
        size.height * 0.5,
      );

      canvas.drawPath(path1, paint1);
      canvas.drawPath(path2, paint2);

      // رسم النقط المتداخلة الصغيرة المضيئة (الدوائر المشبوكة)
      var dotPaint = Paint()
        ..color = secondLineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.4),
        4,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.71, size.height * 0.38),
        4,
        Paint()..color = isDark ? Colors.white : firstLineColor,
      );
    } else {
      // رسم جراف خطي مصغر وناعم ومناسب للكارت الصغير
      path1.moveTo(0, size.height * 0.6);
      path1.cubicTo(
        size.width * 0.3,
        size.height * (variant ? 0.2 : 0.8),
        size.width * 0.6,
        size.height * (variant ? 0.8 : 0.1),
        size.width,
        size.height * 0.4,
      );
      canvas.drawPath(path1, paint1);
      if (!variant) {
        path2.moveTo(0, size.height * 0.4);
        path2.cubicTo(
          size.width * 0.4,
          size.height * 0.3,
          size.width * 0.7,
          size.height * 0.7,
          size.width,
          size.height * 0.3,
        );
        canvas.drawPath(path2, paint2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CurvedChartPainter old) =>
      old.isDark != isDark ||
      old.isMini != isMini ||
      old.variant != variant ||
      old.firstLineColor != firstLineColor ||
      old.secondLineColor != secondLineColor;
}

// الرسام الجانبي لجراف النمو الممتلئ (Stock Growth Mini Gradient Chart)
class MiniGrowthPainter extends CustomPainter {
  final Color color;

  MiniGrowthPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paintLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    var path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width * 0.5,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height * 0.1);

    var fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    var paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant MiniGrowthPainter old) => old.color != color;
}
