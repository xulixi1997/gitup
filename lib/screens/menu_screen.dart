import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../widgets/glitch_scaffold.dart';
import '../core/constants.dart';

import 'permanent_upgrade_screen.dart';
import 'game_screen.dart';
import 'fragment_assembly_screen.dart';
import 'terminal_screen.dart';

import '../core/settings_provider.dart';
import '../widgets/responsive_center.dart';
import '../widgets/menu_button.dart';
import '../widgets/glitch_page_route.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);
    final settings = Provider.of<SettingsProvider>(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Decorative background grid
            Positioned.fill(
              child: CustomPaint(
                painter: _MenuGridPainter(),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: ResponsiveCenter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const SizedBox(height: 60),
                      const _SystemStatusHeader(),
                      const SizedBox(height: 80),
                      // Title with glow
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [GameColors.accent, GameColors.neonBlue, GameColors.accent],
                        ).createShader(bounds),
                        child: Text(
                          'GLITCH_KATANA', 
                          style: GameStyles.glitchTitle.copyWith(
                            fontSize: 42,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '// INFINITY_RONIN_OMEGA // PROTOCOL_04',
                        style: GameStyles.labelText.copyWith(
                          color: GameColors.accent.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 100),
                      MenuButton(
                        label: 'INITIALIZE_SYSTEM',
                        onPressed: () {
                          engine.startGame();
                          Navigator.push(
                            context,
                            GlitchPageRoute(page: const GameScreen()),
                          );
                        },
                        isPrimary: true,
                      ),
                      const SizedBox(height: 20),
                      MenuButton(
                        label: 'NEURAL_UPGRADES',
                        onPressed: () {
                          Navigator.push(
                            context,
                            GlitchPageRoute(page: const PermanentUpgradeScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      MenuButton(
                        label: 'BOSS_RUSH_PROTOCOL',
                        onPressed: () {
                          engine.startBossRush();
                          Navigator.push(
                            context,
                            GlitchPageRoute(page: const GameScreen()),
                          );
                        },
                        isWarning: true,
                      ),
                      const SizedBox(height: 20),
                      MenuButton(
                        label: 'FRAGMENT_ASSEMBLY',
                        onPressed: () {
                          Navigator.push(
                            context,
                            GlitchPageRoute(
                                page: const FragmentAssemblyScreen()),
                          );
                        },
                        isPrimary: false,
                        color: Colors.cyanAccent,
                      ),
                      const SizedBox(height: 20),
                      MenuButton(
                        label: '> TERMINAL_ACCESS',
                        onPressed: () {
                          Navigator.push(
                            context,
                            GlitchPageRoute(
                                page: const TerminalScreen()),
                          );
                        },
                        isPrimary: false,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(height: 80),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow('BEST_NEURAL_SYNC', settings.highScore.toString()),
                            const SizedBox(height: 10),
                            _buildStatRow('DATA_FRAGMENTS', settings.dataFragments.toString(), color: GameColors.expOrb),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, {Color color = Colors.white38}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GameStyles.labelText),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.accent.withOpacity(0.05)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Add some random highlight points
    final highlightPaint = Paint()
      ..color = GameColors.accent.withOpacity(0.1)
      ..strokeWidth = 2.0;
      
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 2, highlightPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), 2, highlightPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 2, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SystemStatusHeader extends StatelessWidget {
  const _SystemStatusHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OPERATOR: RONIN_01', style: GameStyles.labelText.copyWith(fontSize: 8)),
            Text('STATUS: ONLINE', style: GameStyles.labelText.copyWith(fontSize: 8, color: GameColors.expOrb)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('SYNC: 98.4%', style: GameStyles.labelText.copyWith(fontSize: 8)),
            Text('LOC: SECTOR_00', style: GameStyles.labelText.copyWith(fontSize: 8)),
          ],
        ),
      ],
    );
  }
}
