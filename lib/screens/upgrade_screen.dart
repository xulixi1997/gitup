import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../widgets/glitch_scaffold.dart';
import '../core/constants.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);
    final choices = engine.getUpgradeOptions();

    return GlitchScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NEURAL_LEVEL_UP',
              style: TextStyle(
                color: GameColors.accent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'SELECT TACTICAL UPGRADE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            ...choices.map((u) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: _UpgradeButton(
                title: u.title,
                desc: u.description,
                onPressed: () => engine.applyUpgrade(u),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatefulWidget {
  final String title;
  final String desc;
  final VoidCallback onPressed;

  const _UpgradeButton({required this.title, required this.desc, required this.onPressed});

  @override
  State<_UpgradeButton> createState() => _UpgradeButtonState();
}

class _UpgradeButtonState extends State<_UpgradeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isHovered ? GameColors.accent : GameColors.accent.withOpacity(0.3),
              width: 2,
            ),
            color: _isHovered ? GameColors.accent.withOpacity(0.1) : Colors.black,
            boxShadow: _isHovered ? [
              BoxShadow(
                color: GameColors.accent.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: Row(
            children: [
              _buildIcon(widget.title),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: _isHovered ? Colors.white : GameColors.accent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 20,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.desc,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isHovered)
                const Icon(Icons.chevron_right, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String title) {
    IconData iconData;
    final t = title.toLowerCase();
    if (t.contains('damage') || t.contains('attack')) {
      iconData = Icons.bolt;
    } else if (t.contains('speed') || t.contains('fire')) {
      iconData = Icons.speed;
    } else if (t.contains('health') || t.contains('integrity')) {
      iconData = Icons.favorite;
    } else if (t.contains('shield')) {
      iconData = Icons.shield;
    } else if (t.contains('magnet') || t.contains('exp')) {
      iconData = Icons.vibration;
    } else {
      iconData = Icons.add_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _isHovered ? Colors.white24 : Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        iconData,
        color: _isHovered ? Colors.white : GameColors.accent,
        size: 32,
      ),
    );
  }
}
