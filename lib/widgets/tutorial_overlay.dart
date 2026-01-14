import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'menu_button.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const TutorialOverlay({super.key, required this.onDismiss});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  final List<Map<String, String>> _steps = [
    {
      'title': 'MOVEMENT_PROTOCOL',
      'desc': 'DRAG ANYWHERE TO DASH.\nSPEED IS YOUR ONLY DEFENSE.',
      'icon': '⚡',
    },
    {
      'title': 'CHRONO_STASIS',
      'desc': 'STOP MOVING TO SLOW TIME.\nPLAN YOUR NEXT STRIKE.',
      'icon': '⏱',
    },
    {
      'title': 'JUST_DEFEND',
      'desc': 'DASH THROUGH PROJECTILES\nTO HACK THEM.',
      'icon': '🛡',
    },
  ];

  void _nextStep() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepData = _steps[_step];

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '// TUTORIAL_SEQUENCE_0${_step + 1}',
                  key: ValueKey(_step),
                  style: GameStyles.labelText.copyWith(color: GameColors.accent),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    child: child,
                  );
                },
                child: _ShakeWidget(
                  key: ValueKey('${_step}_icon'),
                  hz: 2,
                  offset: const Offset(2, 0),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: GameColors.accent, width: 2),
                      shape: BoxShape.circle,
                      color: GameColors.accent.withOpacity(0.1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      stepData['icon']!,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  stepData['title']!,
                  key: ValueKey('${_step}_title'),
                  style: GameStyles.glitchTitle.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  stepData['desc']!,
                  key: ValueKey('${_step}_desc'),
                  style: GameStyles.bodyText.copyWith(height: 1.5, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              MenuButton(
                key: ValueKey('${_step}_btn'),
                label: _step < _steps.length - 1 ? 'NEXT_SEQUENCE' : 'INITIALIZE_LINK',
                onPressed: _nextStep,
                isPrimary: true,
              ),
            ],
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
    super.key,
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
