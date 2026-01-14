import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../widgets/glitch_scaffold.dart';
import '../core/constants.dart';
import '../core/settings_provider.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _synced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_synced) {
      _syncGameData();
      _synced = true;
    }
  }

  void _syncGameData() {
    final engine = Provider.of<GameEngine>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Sync high score
    settings.updateHighScore(engine.score);

    // Sync data fragments (earned during gameplay)
    // Every 1000 points = 1 fragment
    final fragmentsEarned = (engine.score / 1000).floor();
    if (fragmentsEarned > 0) {
      settings.addDataFragments(fragmentsEarned);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0000AA),
      body: InkWell(
        onTap: () => engine.startGame(),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'CRITICAL_PROCESS_DIED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'CAUSE: ${engine.killerName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'DATA: ${engine.score.toString().padLeft(6, '0')} MB',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'MAX_DANGER: ${engine.difficulty.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'NEURAL_LEVEL: ${engine.player.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              const Center(
                child: _BlinkingText(
                  'TAP TO RESPAWN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _BlinkingText(this.text, {required this.style});

  @override
  State<_BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<_BlinkingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(widget.text, style: widget.style),
    );
  }
}
