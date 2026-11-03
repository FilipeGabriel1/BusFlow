import 'package:flutter/material.dart';

import '../theme.dart';

/// Marca do BusFlow: ônibus com capelo acadêmico e curvas de flow.
class BusFlowMark extends StatelessWidget {
  const BusFlowMark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final box = size * 1.25;
    return SizedBox(
      height: box,
      width: box * _markRatio,
      child: Image.asset(
        'assets/images/logo_mark.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => CustomPaint(
          painter: _BusFlowMarkPainter(
            body: AppColors.primary,
            accent: AppColors.flowBlue,
            dark: AppColors.primaryDark,
            glass: const Color(0xFFBFE3F7),
          ),
        ),
      ),
    );
  }
}

const double _markRatio = 171 / 128;
const double _logoRatio = 416 / 128;

class _BusFlowMarkPainter extends CustomPainter {
  const _BusFlowMarkPainter({
    required this.body,
    required this.accent,
    required this.dark,
    required this.glass,
  });

  final Color body;
  final Color accent;
  final Color dark;
  final Color glass;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 100;
    Offset o(double x, double y) => Offset(x * s, y * s);

    final line = Paint()
      ..color = accent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7 * s;

    canvas.drawLine(o(0, 40), o(20, 40), line);
    canvas.drawLine(o(5, 58), o(20, 58), line);

    final bodyPaint = Paint()..color = body;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(26 * s, 24 * s, 72 * s, 46 * s),
        Radius.circular(13 * s),
      ),
      bodyPaint,
    );

    final glassPaint = Paint()..color = glass;
    final windowRadius = Radius.circular(5 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(34 * s, 33 * s, 16 * s, 15 * s),
        windowRadius,
      ),
      glassPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(55 * s, 33 * s, 16 * s, 15 * s),
        windowRadius,
      ),
      glassPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(76 * s, 33 * s, 16 * s, 15 * s),
        windowRadius,
      ),
      glassPaint,
    );

    final headlight = Paint()..color = accent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(34 * s, 55 * s, 58 * s, 7 * s),
        Radius.circular(4 * s),
      ),
      headlight,
    );

    final wheelOuter = Paint()..color = dark;
    final wheelInner = Paint()..color = Colors.white;
    for (final cx in <double>[46, 84]) {
      canvas.drawCircle(o(cx, 70), 10 * s, wheelOuter);
      canvas.drawCircle(o(cx, 70), 4 * s, wheelInner);
    }
  }

  @override
  bool shouldRepaint(_BusFlowMarkPainter oldDelegate) =>
      body != oldDelegate.body ||
      accent != oldDelegate.accent ||
      dark != oldDelegate.dark ||
      glass != oldDelegate.glass;
}

/// Logo completa: marca + texto "BusFlow".
class BusFlowLogo extends StatelessWidget {
  const BusFlowLogo({
    super.key,
    this.markSize = 28,
    this.fontSize = 16,
    this.showText = true,
  });

  final double markSize;
  final double fontSize;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    if (!showText) return BusFlowMark(size: markSize);
    return SizedBox(
      height: markSize,
      width: markSize * _logoRatio,
      child: Image.asset(
        'assets/images/logo_full.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BusFlowMark(size: markSize),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Bus',
                      style: TextStyle(color: AppColors.primaryDark),
                    ),
                    TextSpan(
                      text: 'Flow',
                      style: TextStyle(color: AppColors.flowBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar de usuário (placeholder).
class BusFlowAvatar extends StatelessWidget {
  const BusFlowAvatar({super.key, this.radius = 16});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(Icons.person, size: radius * 1.2, color: AppColors.primary),
    );
  }
}
