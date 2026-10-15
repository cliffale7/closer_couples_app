import 'package:flutter/material.dart';

import '../../app/closer_theme.dart';

class ConstellationMark extends StatelessWidget {
  const ConstellationMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _ConstellationPainter(progress: reduce ? 0.35 : 0.55),
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = CloserColors.copper.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final star = Paint()..color = CloserColors.teal;
    final points = <Offset>[
      Offset(size.width * 0.18, size.height * 0.62),
      Offset(size.width * 0.38, size.height * 0.28),
      Offset(size.width * 0.58, size.height * 0.48),
      Offset(size.width * 0.78, size.height * 0.22),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, line);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.55, size.width * 0.55, size.height * 0.28),
      0.2,
      2.2 * progress + 0.4,
      false,
      line,
    );
    for (final point in points) {
      canvas.drawCircle(point, 2.6, star);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
