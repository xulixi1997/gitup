import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../widgets/glitch_scaffold.dart';
import '../core/constants.dart';
import '../core/settings_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    final List<_AchievementNodeData> nodes = [
      _AchievementNodeData(
        title: 'DATA_INITIATE',
        description: 'SYNAPTIC LINK ESTABLISHED. SCORE > 5,000',
        progress: (settings.highScore / 5000).clamp(0.0, 1.0),
        icon: Icons.hub,
        offset: const Offset(0, -150),
      ),
      _AchievementNodeData(
        title: 'GLITCH_VETERAN',
        description: 'CORE INTEGRITY TESTED. SCORE > 20,000',
        progress: (settings.highScore / 20000).clamp(0.0, 1.0),
        icon: Icons.security,
        offset: const Offset(-100, -50),
      ),
      _AchievementNodeData(
        title: 'DATA_COLLECTOR',
        description: 'FRAGMENTATION SUCCESSFUL. DATA > 500',
        progress: (settings.dataFragments / 500).clamp(0.0, 1.0),
        icon: Icons.memory,
        offset: const Offset(100, -50),
      ),
      _AchievementNodeData(
        title: 'VOID_WALKER',
        description: 'NEURAL DRIFT DETECTED. DATA > 2,000',
        progress: (settings.dataFragments / 2000).clamp(0.0, 1.0),
        icon: Icons.waves,
        offset: const Offset(-80, 80),
      ),
      _AchievementNodeData(
        title: 'ELITE_OPERATIVE',
        description: 'OMEGA PROTOCOL ACTIVE. SCORE > 50,000',
        progress: (settings.highScore / 50000).clamp(0.0, 1.0),
        icon: Icons.auto_fix_high,
        offset: const Offset(80, 80),
      ),
    ];

    return Stack(
      children: [
        // Background topology lines
        Positioned.fill(
          child: CustomPaint(
            painter: _TopologyPainter(nodes),
          ),
        ),
        // Interactive Nodes
        Center(
          child: SingleChildScrollView(
            child: SizedBox(
              height: 600,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center Core
                  _buildCenterCore(),
                  // Nodes
                  ...nodes.map((node) => _AchievementNode(data: node)),
                ],
              ),
            ),
          ),
        ),
        // Title Overlay
        Positioned(
          top: 60,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEURAL_NODES', style: GameStyles.glitchTitle),
              const SizedBox(height: 4),
              Text('SYSTEM_SYNC_STATUS: ${(nodes.where((n) => n.progress >= 1.0).length / nodes.length * 100).toInt()}%',
                  style: GameStyles.labelText.copyWith(color: GameColors.accent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterCore() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: GameColors.accent.withOpacity(0.1),
        border: Border.all(color: GameColors.accent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: GameColors.accent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: const Center(
        child: Icon(Icons.blur_on, color: GameColors.accent, size: 40),
      ),
    );
  }
}

class _AchievementNodeData {
  final String title;
  final String description;
  final double progress;
  final IconData icon;
  final Offset offset;

  _AchievementNodeData({
    required this.title,
    required this.description,
    required this.progress,
    required this.icon,
    required this.offset,
  });
}

class _AchievementNode extends StatefulWidget {
  final _AchievementNodeData data;

  const _AchievementNode({required this.data});

  @override
  State<_AchievementNode> createState() => _AchievementNodeState();
}

class _AchievementNodeState extends State<_AchievementNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.data.progress >= 1.0;

    return Transform.translate(
      offset: widget.data.offset,
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring (Animated if unlocked)
            if (isUnlocked)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: GameColors.accent.withOpacity(1.0 - _controller.value),
                        width: 1,
                      ),
                    ),
                  );
                },
              ),
            // Node Core
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? GameColors.accent.withOpacity(0.1) : Colors.black,
                border: Border.all(
                  color: isUnlocked ? GameColors.accent : Colors.white24,
                  width: 2,
                ),
                boxShadow: isUnlocked
                    ? [BoxShadow(color: GameColors.accent.withOpacity(0.3), blurRadius: 10)]
                    : [],
              ),
              child: Icon(
                widget.data.icon,
                color: isUnlocked ? GameColors.accent : Colors.white24,
                size: 24,
              ),
            ),
            // Tooltip / Details
            if (_isExpanded)
              Transform.translate(
                offset: const Offset(0, 60),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    border: Border.all(color: GameColors.accent.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.data.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace')),
                      const SizedBox(height: 4),
                      Text(widget.data.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 8, fontFamily: 'monospace')),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: widget.data.progress,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              isUnlocked ? GameColors.accent : Colors.white24),
                          minHeight: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopologyPainter extends CustomPainter {
  final List<_AchievementNodeData> nodes;

  _TopologyPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = GameColors.accent.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var node in nodes) {
      final nodePos = center + node.offset;
      
      // Draw line to center
      canvas.drawLine(center, nodePos, paint);
      
      // Draw some techy accents
      final isUnlocked = node.progress >= 1.0;
      if (isUnlocked) {
        final highlightPaint = Paint()
          ..color = GameColors.accent.withOpacity(0.3)
          ..strokeWidth = 2.0;
        canvas.drawCircle(nodePos, 4, highlightPaint);
      }
    }
    
    // Draw some ambient grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;
    
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
