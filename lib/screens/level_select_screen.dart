import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../core/constants.dart';
import '../core/settings_provider.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text('SELECT_SECTOR', style: GameStyles.glitchTitle),
              const SizedBox(height: 8),
              const Text(
                'CHOOSE TARGET DESTINATION FOR DATA RETRIEVAL',
                style: GameStyles.labelText,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final isUnlocked = index == 0 || settings.highScore > (index * 2000);
                    return _LevelCard(
                      index: index + 1,
                      title: _getSectorName(index),
                      description: _getSectorDescription(index),
                      isUnlocked: isUnlocked,
                      onTap: isUnlocked
                          ? () => _showMissionDetails(context, index, engine)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMissionDetails(BuildContext context, int index, GameEngine engine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MissionDetailSheet(
        index: index,
        engine: engine,
        sectorName: _getSectorName(index),
        threatLevel: _getThreatLevel(index),
        description: _getSectorDescription(index),
      ),
    );
  }

  String _getSectorName(int index) {
    const names = [
      'NEON_CITY_CORE',
      'SILICON_WASTELAND',
      'CYBER_VOID',
      'ORBITAL_STATION',
      'THE_SOURCE'
    ];
    return names[index % names.length];
  }

  String _getSectorDescription(int index) {
    const descriptions = [
      'High-density urban area controlled by the Megacorp.',
      'Abandoned industrial zone filled with rogue drones.',
      'Unstable digital realm where reality fractures.',
      'High-security satellite network guarding the core.',
      'The heart of the system. Final decryption point.'
    ];
    return descriptions[index % descriptions.length];
  }

  String _getThreatLevel(int index) {
    const levels = ['LOW', 'MEDIUM', 'HIGH', 'EXTREME', 'CRITICAL'];
    return levels[index % levels.length];
  }
}

class _LevelCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.index,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isUnlocked ? GameColors.surface : Colors.white.withOpacity(0.02),
            border: Border.all(
              color: isUnlocked ? GameColors.accent.withOpacity(0.4) : Colors.white10,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isUnlocked ? GameColors.accent : Colors.white10,
                    width: 1,
                  ),
                  color: isUnlocked ? GameColors.accent.withOpacity(0.1) : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    isUnlocked ? '0$index' : '??',
                    style: TextStyle(
                      color: isUnlocked ? GameColors.accent : Colors.white24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked ? title : 'LOCKED_SECTOR',
                      style: GameStyles.bodyText.copyWith(
                        color: isUnlocked ? Colors.white : Colors.white24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked ? description : 'REACH HIGHER SCORE TO DECRYPT',
                      style: GameStyles.labelText.copyWith(
                        fontSize: 11,
                        color: isUnlocked ? Colors.white54 : Colors.white10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isUnlocked)
                const Icon(Icons.lock_outline, color: Colors.white10, size: 20)
              else
                const Icon(Icons.chevron_right, color: GameColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionDetailSheet extends StatelessWidget {
  final int index;
  final GameEngine engine;
  final String sectorName;
  final String threatLevel;
  final String description;

  const _MissionDetailSheet({
    required this.index,
    required this.engine,
    required this.sectorName,
    required this.threatLevel,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: GameColors.surface,
        border: const Border(top: BorderSide(color: GameColors.accent, width: 2)),
        boxShadow: [
          BoxShadow(
            color: GameColors.accent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MISSION_BRIEFING: 0${index + 1}', 
                    style: GameStyles.glitchTitle.copyWith(fontSize: 18, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 100,
                    color: GameColors.neonPink,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: GameColors.accent),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildInfoRow('TARGET_SECTOR', sectorName, isHighlight: true),
          _buildInfoRow('THREAT_LEVEL', threatLevel, 
            valueColor: _getThreatColor(threatLevel)),
          _buildInfoRow('INTEL_SUMMARY', description),
          _buildInfoRow('OBJECTIVE', 'Exfiltrate data fragments & neutralize all hostile AI entities in the sector.'),
          const Spacer(),
          const Center(
            child: Text(
              '// WARNING: DATA CORRUPTION DETECTED IN SECTOR //',
              style: TextStyle(
                color: GameColors.neonPink,
                fontSize: 10,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.accent,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(),
                elevation: 10,
                shadowColor: GameColors.accent.withOpacity(0.5),
              ),
              onPressed: () {
                Navigator.pop(context);
                engine.startGame();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'INITIALIZE_INSERTION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _getThreatColor(String level) {
    switch (level) {
      case 'LOW': return Colors.greenAccent;
      case 'MEDIUM': return Colors.yellowAccent;
      case 'HIGH': return Colors.orangeAccent;
      case 'EXTREME': return Colors.redAccent;
      case 'CRITICAL': return GameColors.neonPink;
      default: return Colors.white;
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GameStyles.labelText.copyWith(
            color: GameColors.accent.withOpacity(0.6),
            fontSize: 10,
          )),
          const SizedBox(height: 6),
          Text(
            value, 
            style: GameStyles.bodyText.copyWith(
              color: valueColor ?? (isHighlight ? GameColors.accent : Colors.white),
              fontSize: 15,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
