import 'package:flutter/material.dart';
import '../widgets/glitch_scaffold.dart';
import '../widgets/responsive_center.dart';
import '../core/constants.dart';

class SystemInfoScreen extends StatefulWidget {
  const SystemInfoScreen({super.key});

  @override
  State<SystemInfoScreen> createState() => _SystemInfoScreenState();
}

class _SystemInfoScreenState extends State<SystemInfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlitchScaffold(
      child: ResponsiveCenter(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: GameColors.accent.withOpacity(0.3))),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: GameColors.accent,
                labelColor: GameColors.accent,
                unselectedLabelColor: Colors.white24,
                isScrollable: true,
                labelStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'MANUAL'),
                  Tab(text: 'LEGAL'),
                  Tab(text: 'CREDITS'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ManualTab(),
                  _LegalTab(),
                  _CreditsTab(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('< RETURN_TO_SYSTEM', style: TextStyle(color: Colors.white54, fontFamily: 'monospace')),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ManualTab extends StatelessWidget {
  const _ManualTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection('COMBAT_MECHANICS', [
          '• DRAG & RELEASE to DASH through enemies.',
          '• DASHING grants INVULNERABILITY (Ghost Mode).',
          '• STOP MOVING to enter BULLET TIME (0.3x Speed).',
          '• Dash THROUGH bullets to HACK (Reflect) them.',
        ]),
        _buildSection('SYSTEM_RULES', [
          '• CHAIN KILLS to increase COMBO RANK.',
          '• HIGH COMBO triggers GLITCH PULSE (Clears Screen).',
          '• Collect DATA FRAGMENTS to upgrade stats.',
        ]),
        _buildSection('ENEMIES', [
          '• DRONE: Basic unit. Predictable path.',
          '• SNIPER: Fires high-speed rounds. Dash to dodge.',
          '• DATA_WORM: Armored. Destroy body segments first.',
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// $title',
            style: const TextStyle(color: GameColors.accent, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              item,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4, fontFamily: 'monospace'),
            ),
          )),
        ],
      ),
    );
  }
}

class _LegalTab extends StatelessWidget {
  const _LegalTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _InfoBlock(
          title: 'PRIVACY_POLICY_V1.0',
          content: '''
1. DATA COLLECTION
   - No personal data is collected, stored, or transmitted to external servers.
   - All game progress, settings, and statistics are stored locally on your device using "SharedPreferences".
   - This application operates offline and does not require an internet connection.

2. PERMISSIONS
   - HAPTIC_FEEDBACK: Used for game immersion (can be disabled in Settings).
   - STORAGE: Used strictly for saving game state locally.

3. THIRD PARTY
   - This application does not integrate with third-party analytics or ad networks.
''',
        ),
        SizedBox(height: 30),
        _InfoBlock(
          title: 'TERMS_OF_USE_V1.0',
          content: '''
1. LICENSE
   - GLITCH_KATANA is provided "as is" without warranty of any kind.
   - You are granted a personal, non-exclusive, non-transferable license to use this software.

2. RESTRICTIONS
   - You may not reverse engineer, decompile, or disassemble the software.
   - You may not use the software for any illegal purpose.

3. HEALTH WARNING
   - This game contains flashing lights and rapid visual patterns.
   - Players with photosensitive epilepsy should enable "REDUCE_FLASHING" in Settings or discontinue use immediately if discomfort occurs.
''',
        ),
      ],
    );
  }
}

class _CreditsTab extends StatelessWidget {
  const _CreditsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'GLITCH_KATANA',
            style: GameStyles.glitchTitle,
          ),
          const SizedBox(height: 10),
          Text(
            'VERSION 1.5.0-RC1',
            style: GameStyles.labelText.copyWith(color: Colors.white30),
          ),
          const SizedBox(height: 40),
          const Text('CREATED_BY', style: GameStyles.labelText),
          const SizedBox(height: 10),
          const Text('INFINITY_RONIN_LABS', style: TextStyle(color: GameColors.accent, fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          const Text('POWERED_BY', style: GameStyles.labelText),
          const SizedBox(height: 10),
          const FlutterLogo(size: 40),
          const SizedBox(height: 10),
          const Text('FLUTTER & DART', style: TextStyle(color: Colors.white70, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String content;

  const _InfoBlock({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: GameColors.accent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
