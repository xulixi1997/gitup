import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../game/game_painter.dart';
import '../widgets/glitch_scaffold.dart';
import '../core/constants.dart' hide GameState;
import '../core/settings_provider.dart';
import '../widgets/pause_menu.dart';
import '../widgets/tutorial_overlay.dart';
import 'menu_screen.dart';
import 'game_over_screen.dart';
import 'upgrade_screen.dart';
import 'corruption_select_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Offset? _dragStart;
  Offset? _dragCurrent;

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // Auto-pause for tutorial
    if (!settings.tutorialShown && !engine.paused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!engine.paused) engine.togglePause();
      });
    }

    if (engine.state == GameState.menu) return const MenuScreen();
    if (engine.state == GameState.gameOver) return const GameOverScreen();
    if (engine.state == GameState.upgrades) return const UpgradeScreen();
    if (engine.state == GameState.corruptionSelect) return const CorruptionSelectScreen();

    return GlitchScaffold(
      child: GestureDetector(
        onPanStart: (details) {
          if (engine.paused) return;
          setState(() {
            _dragStart = details.localPosition;
            _dragCurrent = details.localPosition;
          });
        },
        onPanUpdate: (details) {
          if (engine.paused) return;
          setState(() {
            _dragCurrent = details.localPosition;
          });
        },
        onPanEnd: (details) {
          if (engine.paused) return;
          if (_dragStart != null && _dragCurrent != null) {
            engine.handleDragEnd(_dragStart!, _dragCurrent!);
          }
          setState(() {
            _dragStart = null;
            _dragCurrent = null;
          });
        },
        child: Stack(
          children: [
            // Game World (Full Screen)
            Positioned.fill(
              child: CustomPaint(
                painter: GamePainter(engine),
                size: Size.infinite,
              ),
            ),
            
            // UI Overlay (Safe Area)
            SafeArea(
              child: Stack(
                children: [
                  // Combo UI
                  if (engine.combo > 1)
                    Positioned(
                      top: 60,
                      right: 20,
                      child: _ComboCounter(
                        combo: engine.combo,
                        timer: engine.comboTimer,
                        rank: engine.comboRank,
                        color: engine.comboColor,
                      ),
                    ),
                  // Player HUD
                  Positioned(
                    top: 10,
                    left: 20,
                    right: 20,
                    child: _PlayerHUD(engine: engine),
                  ),

                  // Pause Button
                  Positioned(
                    top: 10,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white54),
                      onPressed: engine.togglePause,
                    ),
                  ),
                  
                  // Dash Indicator
                  if (_dragStart != null && _dragCurrent != null && !engine.player.isDashing)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DashIndicatorPainter(_dragStart!, _dragCurrent!),
                      ),
                    ),
                    
                  // Stance Switch Button
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => engine.switchStance(),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(color: GameColors.accent, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.change_circle, 
                            color: GameColors.accent, 
                            size: 32
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Overlays
                  if (engine.paused && settings.tutorialShown) const PauseMenu(),
                  
                  if (!settings.tutorialShown)
                    TutorialOverlay(
                      onDismiss: () {
                        settings.setTutorialShown(true);
                        engine.paused = false;
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboCounter extends StatelessWidget {
  final int combo;
  final double timer;
  final String rank;
  final Color color;

  const _ComboCounter({
    required this.combo,
    required this.timer,
    required this.rank,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RANK_',
              style: GameStyles.labelText.copyWith(color: color.withOpacity(0.5), fontSize: 10),
            ),
            Text(
              rank,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'COMBO',
          style: GameStyles.labelText.copyWith(color: color.withOpacity(0.7), fontSize: 12),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'X',
              style: TextStyle(
                color: color.withOpacity(0.5),
                fontSize: 20,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$combo',
              style: TextStyle(
                color: color,
                fontSize: 48,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: color,
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 2,
          color: Colors.white10,
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: (timer / 2.0).clamp(0.0, 1.0),
            child: Container(color: color),
          ),
        ),
      ],
    );
  }
}

class _PlayerHUD extends StatelessWidget {
  final GameEngine engine;

  const _PlayerHUD({required this.engine});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('INTEGRITY_SYNC', style: GameStyles.labelText),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    engine.player.maxIntegrity,
                    (index) => Container(
                      width: 20,
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index < engine.player.integrity
                            ? (engine.player.integrity <= 1 ? GameColors.error : GameColors.accent)
                            : Colors.white10,
                        border: Border.all(
                          color: index < engine.player.integrity ? Colors.transparent : Colors.white24,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('SYNC_SCORE', style: GameStyles.labelText),
                Text(
                  engine.score.toString().padLeft(8, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 15),
        // XP Bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('NEURAL_EXP [LVL ${engine.player.level}]', style: GameStyles.labelText),
                Text('${engine.player.xp}/${engine.player.nextLevelXp}', style: GameStyles.labelText),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: double.infinity,
              color: Colors.white10,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (engine.player.xp / engine.player.nextLevelXp).clamp(0.0, 1.0),
                child: Container(color: GameColors.expOrb),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashIndicatorPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  DashIndicatorPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.accent.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
    canvas.drawCircle(start, 5, paint);
    canvas.drawCircle(end, 10, paint);
  }

  @override
  bool shouldRepaint(covariant DashIndicatorPainter oldDelegate) => 
    oldDelegate.start != start || oldDelegate.end != end;
}
