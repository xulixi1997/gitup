import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class _MenuButtonState extends State<MenuButton> {
  bool _isPressed = false;

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

    return GestureDetector(
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
            // Glitch Effect Layer (only visible on press or random idle)
            if (_isPressed)
              Positioned.fill(
                child: Container(
                  color: baseColor.withOpacity(0.1),
                ).animate(onPlay: (c) => c.repeat()).shake(
                      hz: 50,
                      offset: const Offset(2, 0),
                    ),
              ),
            
            // Text Label
            Text(
              widget.label,
              style: TextStyle(
                color: _isPressed ? GameColors.playerGlitch : textColor,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 12,
              ),
            )
                .animate(target: _isPressed ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 100.ms)
                .then()
                .shake(hz: 8, offset: const Offset(1, 1)), // Subtle shake on press
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }
}
