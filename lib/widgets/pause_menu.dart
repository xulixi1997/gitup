import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart' hide GameState;
import '../game/game_engine.dart';
import 'menu_button.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context, listen: false);

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '// SYSTEM_PAUSED',
              style: GameStyles.glitchTitle.copyWith(fontSize: 32),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds, color: GameColors.accent)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.2, end: 0),
            const SizedBox(height: 10),
            Text(
              'WAITING_FOR_INPUT...',
              style: GameStyles.labelText.copyWith(
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            MenuButton(
              label: 'RESUME_PROTOCOL',
              onPressed: () => engine.togglePause(),
              isPrimary: true,
            ),
            const SizedBox(height: 20),
            MenuButton(
              label: 'ABORT_MISSION',
              onPressed: () {
                engine.togglePause(); // Unpause logic state
                engine.state = GameState.menu; // Force state to menu
                engine.notifyListeners(); // Ensure UI updates
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              isWarning: true,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
