import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glitch_scaffold.dart';
import 'menu_screen.dart';
import 'level_select_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MenuScreen(),
    const LevelSelectScreen(),
    const AchievementsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GlitchEffect(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: GameColors.accent, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: GameColors.neonBlue,
              blurRadius: 10,
              spreadRadius: -8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: GameColors.accent,
          unselectedItemColor: Colors.white24,
          elevation: 0,
          selectedLabelStyle: GameStyles.labelText.copyWith(
            fontSize: 10,
            color: GameColors.accent,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GameStyles.labelText.copyWith(
            fontSize: 10,
            color: Colors.white24,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'CORE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers),
              label: 'SECTORS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_outlined),
              activeIcon: Icon(Icons.military_tech),
              label: 'NODES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.terminal_outlined),
              activeIcon: Icon(Icons.terminal),
              label: 'SYSTEM',
            ),
          ],
        ),
      ),
    );
  }
}
