import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

class MenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isWarning;
  final Color? color;

  const MenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isWarning = false,
    this.color,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _entryFade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ??
        (widget.isWarning
            ? GameColors.enemy
            : (widget.isPrimary ? GameColors.accent : Colors.white10));
    final textColor = widget.color ??
        (widget.isWarning
            ? GameColors.enemy
            : (widget.isPrimary ? GameColors.accent : Colors.white70));

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: 240,
            height: 50,
            decoration: BoxDecoration(
              color: widget.isWarning || widget.isPrimary || widget.color != null
                  ? baseColor.withOpacity(_isPressed ? 0.2 : 0.05)
                  : Colors.transparent,
              border: Border.all(
                color: _isPressed ? GameColors.playerGlitch : baseColor,
                width: _isPressed ? 2 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glitch Effect Layer
                if (_isPressed)
                  Positioned.fill(
                    child: _ShakeWidget(
                      hz: 50,
                      offset: const Offset(2, 0),
                      child: Container(
                        color: baseColor.withOpacity(0.1),
                      ),
                    ),
                  ),

                // Text Label
                AnimatedScale(
                  scale: _isPressed ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: _isPressed
                      ? _ShakeWidget(
                          hz: 8,
                          offset: const Offset(1, 1),
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: GameColors.playerGlitch,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : Text(
                          widget.label,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShakeWidget extends StatefulWidget {
  final Widget child;
  final double hz;
  final Offset offset;

  const _ShakeWidget({
    required this.child,
    required this.hz,
    required this.offset,
  });

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1000 / widget.hz).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dx = (_random.nextDouble() * 2 - 1) * widget.offset.dx;
        final dy = (_random.nextDouble() * 2 - 1) * widget.offset.dy;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
