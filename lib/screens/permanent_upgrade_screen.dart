import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../widgets/glitch_scaffold.dart';
import '../core/constants.dart';
import '../core/settings_provider.dart';

class PermanentUpgradeScreen extends StatelessWidget {
  const PermanentUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return GlitchScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              'NEURAL_DATA_CENTER',
              style: GameStyles.glitchTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 10),
            Text(
              'DATA_FRAGMENTS: ${settings.dataFragments}',
              style: GameStyles.bodyText.copyWith(color: GameColors.expOrb, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                children: [
                  _UpgradeTile(
                    title: 'MAX_INTEGRITY',
                    level: settings.maxIntegrityLevel,
                    cost: (settings.maxIntegrityLevel + 1) * 10,
                    onPressed: settings.dataFragments >= (settings.maxIntegrityLevel + 1) * 10
                        ? () {
                            settings.addDataFragments(-((settings.maxIntegrityLevel + 1) * 10));
                            settings.setMaxIntegrityLevel(settings.maxIntegrityLevel + 1);
                          }
                        : null,
                  ),
                  _UpgradeTile(
                    title: 'ATTACK_DAMAGE',
                    level: settings.attackDamageLevel,
                    cost: (settings.attackDamageLevel + 1) * 15,
                    onPressed: settings.dataFragments >= (settings.attackDamageLevel + 1) * 15
                        ? () {
                            settings.addDataFragments(-((settings.attackDamageLevel + 1) * 15));
                            settings.setAttackDamageLevel(settings.attackDamageLevel + 1);
                          }
                        : null,
                  ),
                  _UpgradeTile(
                    title: 'DATA_MAGNET',
                    level: settings.dataMagnetUnlocked ? 1 : 0,
                    cost: 50,
                    isBoolean: true,
                    onPressed: !settings.dataMagnetUnlocked && settings.dataFragments >= 50
                        ? () {
                            settings.addDataFragments(-50);
                            settings.setDataMagnetUnlocked(true);
                          }
                        : null,
                  ),
                ],
              ),
            ),
            _BackButton(
              label: 'BACK_TO_TERMINAL',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BackButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: GameColors.accent, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      child: Text(
        label,
        style: GameStyles.labelText.copyWith(color: GameColors.accent),
      ),
    );
  }
}

class _UpgradeTile extends StatelessWidget {
  final String title;
  final int level;
  final int cost;
  final bool isBoolean;
  final VoidCallback? onPressed;

  const _UpgradeTile({
    required this.title,
    required this.level,
    required this.cost,
    this.isBoolean = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: onPressed != null ? GameColors.accent.withOpacity(0.3) : Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(isBoolean ? (level > 0 ? 'STATUS: ACTIVE' : 'STATUS: OFFLINE') : 'CURRENT_LVL: $level',
                    style: GameStyles.labelText.copyWith(fontSize: 10, color: level > 0 ? GameColors.accent : Colors.white38)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (onPressed != null || level == 0 || !isBoolean)
                Text('COST: $cost', style: GameStyles.labelText.copyWith(color: onPressed != null ? GameColors.expOrb : Colors.white24)),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: onPressed != null ? GameColors.accent : Colors.white10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    isBoolean && level > 0 ? 'MAXED' : 'UPGRADE',
                    style: TextStyle(
                      color: onPressed != null ? GameColors.accent : Colors.white24,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: GameColors.accent, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: Colors.black,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
