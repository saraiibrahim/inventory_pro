import 'package:flutter/material.dart';

class SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  SparklinePainter({required this.dataPoints, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final path = Path();
    final areaPath = Path();

    double max = dataPoints.reduce((a, b) => a > b ? a : b);
    double min = dataPoints.reduce((a, b) => a < b ? a : b);
    double range = max - min == 0 ? 1.0 : max - min;
    double widthStep = size.width / (dataPoints.length - 1);

    List<Offset> points = [];
    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * widthStep;
      double normalizedY = (dataPoints[i] - min) / range;
      double y =
          size.height -
          (normalizedY * size.height * 0.8) -
          (size.height * 0.1); // ملمومة من الهوامش عشان متبقاش طايرة برة
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    areaPath.moveTo(points[0].dx, size.height);
    areaPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      Offset p0 = points[i];
      Offset p1 = points[i + 1];

      double controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      double controlY1 = p0.dy;
      double controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      double controlY2 = p1.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
      areaPath.cubicTo(
        controlX1,
        controlY1,
        controlX2,
        controlY2,
        p1.dx,
        p1.dy,
      );
    }

    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    final Shader horizontalFadeShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 1.0),
        color.withValues(alpha: 1.0),
        color.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.1, 0.9, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..shader = horizontalFadeShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.color != color;
  }
}
