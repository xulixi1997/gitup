import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
              Text(
                '// TUTORIAL_SEQUENCE_0${_step + 1}',
                style: GameStyles.labelText.copyWith(color: GameColors.accent),
              ).animate(key: ValueKey(_step)).fadeIn(),
              const SizedBox(height: 20),
              Container(
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
              )
                  .animate(key: ValueKey('${_step}_icon'))
                  .scale(duration: 400.ms, curve: Curves.easeOutBack)
                  .then()
                  .shake(hz: 2, offset: const Offset(2, 0)),
              const SizedBox(height: 40),
              Text(
                stepData['title']!,
                style: GameStyles.glitchTitle.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey('${_step}_title')).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              Text(
                stepData['desc']!,
                style: GameStyles.bodyText.copyWith(height: 1.5, fontSize: 16),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey('${_step}_desc')).fadeIn(delay: 200.ms),
              const SizedBox(height: 60),
              MenuButton(
                label: _step < _steps.length - 1 ? 'NEXT_SEQUENCE' : 'INITIALIZE_LINK',
                onPressed: _nextStep,
                isPrimary: true,
              ).animate(key: ValueKey('${_step}_btn')).fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
