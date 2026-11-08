import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_weather_demo/data/models/weather.dart';

class TemperatureCurve extends StatelessWidget {
  const TemperatureCurve({
    super.key,
    required this.items,
    required this.locale,
  });

  final List<HourlyForecastItem> items;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 360.0);
        return SizedBox(
          width: width,
          height: 176,
          child: CustomPaint(
            painter: _CurvePainter(items: items, locale: locale),
          ),
        );
      },
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({required this.items, required this.locale});

  final List<HourlyForecastItem> items;
  final String locale;

  static const padX = 18.0;
  static const padTop = 28.0;
  static const padBottom = 32.0;

  @override
  void paint(Canvas canvas, Size size) {
    final temps = items.map((e) => e.temperature).toList();
    final minTemp = temps.reduce(math.min);
    final maxTemp = temps.reduce(math.max);
    final span = math.max(maxTemp - minTemp, 1.0);
    final innerWidth = size.width - padX * 2;
    final innerHeight = size.height - padTop - padBottom;

    final points = <Offset>[];
    for (var i = 0; i < items.length; i++) {
      final x = items.length == 1
          ? size.width / 2
          : padX + (i / (items.length - 1)) * innerWidth;
      final y = padTop + ((maxTemp - items[i].temperature) / span) * innerHeight;
      points.add(Offset(x, y));
    }

    final path = _smoothPath(points);
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height - padBottom)
      ..lineTo(points.first.dx, size.height - padBottom)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, padTop),
        Offset(0, size.height - padBottom),
        [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final minIndex = temps.indexOf(minTemp);
    final maxIndex = temps.indexOf(maxTemp);
    for (final index in {minIndex, maxIndex}) {
      final p = points[index];
      canvas.drawCircle(p, 3.5, Paint()..color = Colors.white);
      final label = '${temps[index].round()}°';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height - 8));
    }

    final step = items.length <= 8
        ? 1
        : items.length <= 16
            ? 3
            : 4;
    final tickIndexes = <int>{};
    for (var i = 0; i < items.length; i += step) {
      tickIndexes.add(i);
    }
    tickIndexes.add(items.length - 1);

    for (final i in tickIndexes) {
      final label = _formatHour(items[i].time, locale);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(points[i].dx - tp.width / 2, size.height - padBottom + 10),
      );
    }
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) return path;

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      final c1x = p1.dx + (p2.dx - p0.dx) / 6;
      final c1y = p1.dy + (p2.dy - p0.dy) / 6;
      final c2x = p2.dx - (p3.dx - p1.dx) / 6;
      final c2y = p2.dy - (p3.dy - p1.dy) / 6;
      path.cubicTo(c1x, c1y, c2x, c2y, p2.dx, p2.dy);
    }
    return path;
  }

  String _formatHour(String time, String locale) {
    final hour = int.tryParse(time.substring(11, 13)) ?? 0;
    if (locale == 'zh') {
      return '$hour时';
    }
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour < 12 ? 'AM' : 'PM';
    return '$h12 $suffix';
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.locale != locale;
  }
}
