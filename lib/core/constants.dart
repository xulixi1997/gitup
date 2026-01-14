import 'package:flutter/material.dart';

class GameColors {
  static const Color background = Color(0xFF020202);
  static const Color surface = Color(0xFF121212);
  static const Color player = Colors.white;
  static const Color playerGlitch = Color(0xFF00FFFF);
  static const Color enemy = Color(0xFFFFCC00);
  static const Color elite = Color(0xFFFFD700);
  static const Color boss = Color(0xFFFF004D);
  static const Color projectile = Color(0xFFFF004D);
  static const Color playerProjectile = Color(0xFF00FFFF);
  static const Color expOrb = Color(0xFF00FF00);
  static const Color uiText = Colors.white;
  static const Color accent = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF00FF);
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color warning = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF004D);
}

enum GameState { boot, menu, playing, gameOver, upgrades }

class GameStyles {
  static const TextStyle glitchTitle = TextStyle(
    color: GameColors.accent,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
    letterSpacing: 4,
    shadows: [
      Shadow(color: GameColors.neonPink, offset: Offset(2, 0)),
      Shadow(color: GameColors.neonBlue, offset: Offset(-2, 0)),
    ],
  );

  static const TextStyle bodyText = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontFamily: 'monospace',
    letterSpacing: 1.2,
  );

  static const TextStyle labelText = TextStyle(
    color: Colors.white38,
    fontSize: 10,
    fontFamily: 'monospace',
    letterSpacing: 2,
  );
}

class GameConstants {
  static const double bulletTimeScale = 0.3;
  static const int glitchPulseCombo = 10;
  static const double dashSpeed = 1600.0;
  static const double baseEnemySpeed = 100.0;
  static const double expMagnetRadius = 250.0;
}
