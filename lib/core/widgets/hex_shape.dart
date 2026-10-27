import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The hexagon from the Busiserve mark, used as the app's signature shape.
Path hexagonPath(Size size, {double cornerRadius = 0}) {
  final w = size.width;
  final h = size.height;
  final points = <Offset>[
    for (var i = 0; i < 6; i++)
      Offset(
        w / 2 + (w / 2) * math.cos(math.pi / 180 * (60 * i - 90)),
        h / 2 + (h / 2) * math.sin(math.pi / 180 * (60 * i - 90)),
      ),
  ];
  if (cornerRadius <= 0) return Path()..addPolygon(points, true);
  final path = Path();
  for (var i = 0; i < points.length; i++) {
    final prev = points[(i - 1 + points.length) % points.length];
    final cur = points[i];
    final next = points[(i + 1) % points.length];
    final a = Offset.lerp(cur, prev, cornerRadius / (cur - prev).distance)!;
    final b = Offset.lerp(cur, next, cornerRadius / (cur - next).distance)!;
    if (i == 0) {
      path.moveTo(a.dx, a.dy);
    } else {
      path.lineTo(a.dx, a.dy);
    }
    path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
  }
  return path..close();
}

class HexClipper extends CustomClipper<Path> {
  const HexClipper({this.cornerRadius = 6});
  final double cornerRadius;
  @override
  Path getClip(Size size) => hexagonPath(size, cornerRadius: cornerRadius);
  @override
  bool shouldReclip(HexClipper oldClipper) => oldClipper.cornerRadius != cornerRadius;
}

/// Icon inside a filled hexagon. Used for service icons and status marks.
class HexBadge extends StatelessWidget {
  const HexBadge({
    super.key,
    required this.icon,
    this.size = 52,
    this.gradient,
    this.color,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final double size;
  final Gradient? gradient;
  final Color? color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const HexClipper(),
      child: Container(
        width: size,
        height: size * 1.08,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primary,
          gradient: gradient,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: size * 0.44),
      ),
    );
  }
}

/// Faint hexagon lattice with a rising trace, painted behind hero panels.
class HexLatticePainter extends CustomPainter {
  const HexLatticePainter({required this.color, this.accent});

  final Color color;
  final Color? accent;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const r = 26.0;
    final dx = r * math.sqrt(3);
    const dy = r * 1.5;
    var row = 0;
    for (var y = -r; y < size.height + r; y += dy, row++) {
      final offset = row.isOdd ? dx / 2 : 0.0;
      for (var x = -dx + offset; x < size.width + dx; x += dx) {
        final hex = hexagonPath(const Size(r * 1.732, r * 2)).shift(Offset(x, y));
        canvas.drawPath(hex, stroke);
      }
    }
    if (accent != null) {
      final trace = Paint()
        ..shader = LinearGradient(colors: [accent!.withValues(alpha: 0), accent!])
            .createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final p = Path()
        ..moveTo(size.width * 0.05, size.height * 0.92)
        ..lineTo(size.width * 0.38, size.height * 0.62)
        ..lineTo(size.width * 0.52, size.height * 0.74)
        ..lineTo(size.width * 0.92, size.height * 0.22);
      canvas.drawPath(p, trace);
      final head = Paint()..color = accent!;
      final tip = Offset(size.width * 0.92, size.height * 0.22);
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx + 8, tip.dy - 10)
          ..lineTo(tip.dx - 10, tip.dy - 4)
          ..lineTo(tip.dx + 2, tip.dy + 10)
          ..close(),
        head,
      );
    }
  }

  @override
  bool shouldRepaint(HexLatticePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.accent != accent;
}
