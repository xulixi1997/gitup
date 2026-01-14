import 'package:flutter/material.dart';
import '../widgets/glitch_scaffold.dart';
import '../core/constants.dart';
import '../widgets/glitch_page_route.dart';
import 'system_info_screen.dart';

import 'package:provider/provider.dart';
import '../core/settings_provider.dart';
import '../widgets/responsive_center.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return GlitchScaffold(
      child: ResponsiveCenter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView(
            children: [
              const SizedBox(height: 60),
              Text('SYSTEM_CONFIG', style: GameStyles.glitchTitle),
              const SizedBox(height: 8),
              const Text(
                'CALIBRATE OPERATIONAL PARAMETERS',
                style: GameStyles.labelText,
              ),
              const SizedBox(height: 40),
              _buildSectionHeader('HARDWARE_INTERFACE'),
              _buildToggle(
                context,
                'HAPTIC_LINK',
                'Neural tactile synchronization',
                settings.hapticEnabled,
                (v) => settings.setHapticEnabled(v),
              ),
              _buildToggle(
                context,
                'VISUAL_GLITCH_SIM',
                'CRT distortion and signal noise',
                settings.glitchEnabled,
                (v) => settings.setGlitchEnabled(v),
              ),
              _buildToggle(
                context,
                'REDUCE_FLASHING',
                'Photosensitive mode: Reduce strobing',
                settings.reduceFlashing,
                (v) => settings.setReduceFlashing(v),
              ),
              const SizedBox(height: 30),
              _buildSectionHeader('DATA_MANAGEMENT'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'ERASE_LOCAL_MEMORY',
                  style: TextStyle(
                    color: GameColors.error,
                    fontFamily: 'monospace',
                  ),
                ),
                subtitle: const Text(
                  'Wipe all progression and fragments',
                  style: GameStyles.labelText,
                ),
                trailing: const Icon(
                  Icons.delete_forever,
                  color: GameColors.error,
                ),
                onTap: () => _showDeleteDialog(context, settings),
              ),
              const SizedBox(height: 30),
              _buildSectionHeader('COMPLIANCE_PROTOCOL'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'SYSTEM_MANUAL_&_LEGAL',
                  style: TextStyle(
                    color: GameColors.accent,
                    fontFamily: 'monospace',
                  ),
                ),
                subtitle: const Text(
                  'Manual, Privacy Policy, Credits',
                  style: GameStyles.labelText,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: GameColors.accent,
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    GlitchPageRoute(page: const SystemInfoScreen()),
                  );
                },
              ),
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Text(
                      'BUILD_VER: 1.5.0-RC1',
                      style: GameStyles.labelText.copyWith(
                        color: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DESIGN: INFINITY_RONIN_LABS',
                      style: GameStyles.labelText.copyWith(
                        color: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10),
      child: Row(
        children: [
          Container(width: 4, height: 16, color: GameColors.accent),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: GameColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context,
    String label,
    String sub,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            border: Border.all(
              color: value
                  ? GameColors.accent.withOpacity(0.3)
                  : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: GameStyles.labelText.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Custom terminal-style switch
              Container(
                width: 50,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: value ? GameColors.accent : Colors.white24,
                  ),
                  color: value
                      ? GameColors.accent.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: value ? GameColors.accent : Colors.white24,
                        child: Center(
                          child: Icon(
                            value ? Icons.check : Icons.close,
                            size: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.surface,
        title: const Text(
          'CRITICAL_WARNING',
          style: TextStyle(color: GameColors.error, fontFamily: 'monospace'),
        ),
        content: const Text(
          'Are you sure you want to erase all neural data? This cannot be undone.',
          style: GameStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              settings.clearData();
              Navigator.pop(context);
            },
            child: const Text(
              'ERASE',
              style: TextStyle(color: GameColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
