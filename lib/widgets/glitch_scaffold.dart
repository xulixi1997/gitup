import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/settings_provider.dart';

class GlitchScaffold extends StatelessWidget {
  final Widget child;
  final List<Widget>? overlay;

  const GlitchScaffold({super.key, required this.child, this.overlay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GlitchEffect(
        overlay: overlay,
        child: child,
      ),
    );
  }
}

class GlitchEffect extends StatefulWidget {
  final Widget child;
  final List<Widget>? overlay;

  const GlitchEffect({super.key, required this.child, this.overlay});

  @override
  State<GlitchEffect> createState() => _GlitchEffectState();
}

class _GlitchEffectState extends State<GlitchEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    if (!settings.glitchEnabled) {
      return widget.child;
    }

    return Stack(
      children: [
        // Background Grid
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: GridPainter(progress: _controller.value),
              );
            },
          ),
        ),
        widget.child,
        // Animated CRT effects
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final reduceFlashing = settings.reduceFlashing;
                final isGlitching = !reduceFlashing && (DateTime.now().millisecondsSinceEpoch % 2000 < 150);
                
                return CustomPaint(
                  painter: ScanlinePainter(
                    progress: _controller.value,
                    flicker: reduceFlashing 
                        ? 0.0 
                        : ((DateTime.now().millisecondsSinceEpoch % 100 < 10) ? 0.05 : 0.0),
                    glitchIntensity: isGlitching ? 1.0 : 0.0,
                  ),
                );
              },
            ),
          ),
        ),
        // Vignette effect
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),
        if (widget.overlay != null) ...widget.overlay!,
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final double progress;
  GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.accent.withOpacity(0.05)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    final offset = (progress * spacing) % spacing;

    // Vertical lines
    for (double i = offset; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Horizontal lines
    for (double i = offset; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => oldDelegate.progress != progress;
}

class ScanlinePainter extends CustomPainter {
  final double progress;
  final double flicker;
  final double glitchIntensity;

  ScanlinePainter({
    required this.progress,
    required this.flicker,
    required this.glitchIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scanlines
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1 + flicker)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.height; i += 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Moving scanline bar
    final movingY = (progress * size.height) % size.height;
    final movingPaint = Paint()
      ..color = GameColors.accent.withOpacity(0.02)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, movingY, size.width, 40), movingPaint);

    // Glitch bars
    if (glitchIntensity > 0) {
      final random = DateTime.now().millisecondsSinceEpoch;
      final glitchPaint = Paint()..color = GameColors.neonPink.withOpacity(0.1);
      for (int i = 0; i < 3; i++) {
        final h = 2.0 + (random % 20);
        final y = (random * (i + 1)) % size.height;
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, h), glitchPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.flicker != flicker ||
      oldDelegate.glitchIntensity != glitchIntensity;
}
