import 'package:flutter/material.dart';

import 'package:flutter_weather_demo/domain/map_codes.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.code,
    this.isDay = true,
    this.size = 28,
  });

  final int code;
  final bool isDay;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WeatherIconPainter(
          kind: getWeatherIconKind(code),
          isDay: isDay,
        ),
      ),
    );
  }
}

class _WeatherIconPainter extends CustomPainter {
  _WeatherIconPainter({required this.kind, required this.isDay});

  final WeatherIconKind kind;
  final bool isDay;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32;
    canvas.scale(scale);

    switch (kind) {
      case WeatherIconKind.clear:
        _drawSun(canvas, night: !isDay);
      case WeatherIconKind.mainlyClear:
        canvas.save();
        canvas.translate(-2, -3);
        canvas.scale(0.78);
        _drawSun(canvas, night: !isDay);
        canvas.restore();
        canvas.save();
        canvas.translate(2, 2);
        _drawCloud(canvas, opacity: 0.88);
        canvas.restore();
      case WeatherIconKind.partlyCloudy:
        canvas.save();
        canvas.translate(-1, -4);
        canvas.scale(0.7);
        _drawSun(canvas, night: !isDay);
        canvas.restore();
        _drawCloud(canvas);
      case WeatherIconKind.overcast:
        _drawCloud(canvas, opacity: 0.75, dy: -2);
        _drawCloud(canvas, opacity: 0.95, dy: 2);
      case WeatherIconKind.fog:
        _drawFog(canvas);
      case WeatherIconKind.drizzle:
        _drawCloud(canvas);
        _drawDrops(canvas, heavy: false);
      case WeatherIconKind.rain:
      case WeatherIconKind.showers:
      case WeatherIconKind.freezingRain:
        _drawCloud(canvas);
        _drawDrops(canvas, heavy: true);
      case WeatherIconKind.snow:
      case WeatherIconKind.snowShowers:
        _drawCloud(canvas);
        _drawFlakes(canvas);
      case WeatherIconKind.thunderstorm:
        _drawCloud(canvas);
        _drawBolt(canvas);
      case WeatherIconKind.unknown:
        _drawCloud(canvas, opacity: 0.6);
    }
  }

  void _drawSun(Canvas canvas, {required bool night}) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    if (night) {
      final path = Path()
        ..moveTo(18, 8.5)
        ..cubicTo(22, 8.5, 25.5, 12, 25.5, 16)
        ..cubicTo(25.5, 21, 21.5, 25, 16.5, 25)
        ..cubicTo(12, 25, 8.5, 22, 8, 18)
        ..cubicTo(14, 20, 20, 14, 18, 8.5)
        ..close();
      canvas.drawPath(path, paint);
      return;
    }
    canvas.drawCircle(const Offset(16, 16), 5.5, paint);
    final ray = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const rays = [
      [Offset(16, 3.5), Offset(16, 6.3)],
      [Offset(16, 25.7), Offset(16, 28.5)],
      [Offset(3.5, 16), Offset(6.3, 16)],
      [Offset(25.7, 16), Offset(28.5, 16)],
      [Offset(7.2, 7.2), Offset(9.2, 9.2)],
      [Offset(22.8, 22.8), Offset(24.8, 24.8)],
      [Offset(7.2, 24.8), Offset(9.2, 22.8)],
      [Offset(22.8, 9.2), Offset(24.8, 7.2)],
    ];
    for (final r in rays) {
      canvas.drawLine(r[0], r[1], ray);
    }
  }

  void _drawCloud(Canvas canvas, {double opacity = 0.95, double dy = 0}) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    final path = Path()
      ..moveTo(10.5, 22.5 + dy)
      ..lineTo(22.7, 22.5 + dy)
      ..cubicTo(26.5, 22.5 + dy, 28.5, 19 + dy, 27.5, 16 + dy)
      ..cubicTo(30, 15.5 + dy, 30, 12 + dy, 26.5, 12 + dy)
      ..cubicTo(25.5, 7 + dy, 18, 6 + dy, 15, 10 + dy)
      ..cubicTo(12, 8 + dy, 8, 10 + dy, 8.5, 14 + dy)
      ..cubicTo(5, 14.5 + dy, 5, 22.5 + dy, 10.5, 22.5 + dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawDrops(Canvas canvas, {required bool heavy}) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    void drop(double x, double y) {
      final path = Path()
        ..moveTo(x, y)
        ..cubicTo(x + 1.5, y + 2, x + 1.5, y + 3.5, x, y + 4)
        ..cubicTo(x - 1.5, y + 3.5, x - 1.5, y + 2, x, y);
      canvas.drawPath(path, paint);
    }

    drop(10.5, 20.5);
    drop(15.5, 21.5);
    if (heavy) drop(20.5, 20.5);
  }

  void _drawFlakes(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    void flake(double x, double y) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 4), paint);
      canvas.drawLine(Offset(x - 1.8, y + 1.2), Offset(x + 1.8, y + 2.8), paint);
      canvas.drawLine(Offset(x - 1.8, y + 2.8), Offset(x + 1.8, y + 1.2), paint);
    }

    flake(11, 23);
    flake(18, 22.5);
  }

  void _drawBolt(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    final path = Path()
      ..moveTo(16.8, 18.8)
      ..lineTo(14, 24.5)
      ..lineTo(16.2, 24.5)
      ..lineTo(14.8, 29.7)
      ..lineTo(20.4, 22.3)
      ..lineTo(17.8, 22.3)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawFog(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(8, 14), const Offset(24, 14), paint);
    canvas.drawLine(const Offset(6, 18), const Offset(26, 18), paint);
    canvas.drawLine(const Offset(9, 22), const Offset(23, 22), paint);
  }

  @override
  bool shouldRepaint(covariant _WeatherIconPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.isDay != isDay;
  }
}
