import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/vector2.dart';
import '../core/constants.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/projectile.dart';
import '../models/exp_orb.dart';
import '../models/particle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/settings_provider.dart';

import '../models/corruption.dart';
import '../models/fragment.dart';

import 'wave_manager.dart';
import 'fragment_manager.dart';

class FloatingText {
  Vec2 pos;
  String text;
  Color color;
  double life;
  double maxLife;
  double velocityY;

  FloatingText({
    required this.pos,
    required this.text,
    required this.color,
    this.life = 1.0,
    this.velocityY = -50.0,
  }) : maxLife = life;
}

class UpgradeOption {
  final String title;
  final String description;
  final VoidCallback onApply;

  UpgradeOption({
    required this.title,
    required this.description,
    required this.onApply,
  });
}

enum GameState { menu, playing, gameOver, upgrades, corruptionSelect }

enum GameMode { story, bossRush }

class GameEngine extends ChangeNotifier {
  SettingsProvider? settings;

  void updateSettings(SettingsProvider newSettings) {
    settings = newSettings;
    _fragmentManager = FragmentManager(newSettings);
  }

  GameState state = GameState.menu;
  GameMode mode = GameMode.story;
  bool paused = false;

  late Player player;
  List<Enemy> enemies = [];
  List<Projectile> projectiles = [];
  List<ExpOrb> expOrbs = [];
  List<Particle> particles = [];

  // Corruption Protocol
  List<Corruption> activeCorruptions = [];
  List<Corruption> availableCorruptions = [];

  double timeScale = 1.0;
  int score = 0;
  int combo = 0;
  double comboTimer = 0.0;
  double gameTime = 0.0;

  // Wave Management
  final WaveManager _waveManager = WaveManager();

  // Fragment System
  FragmentManager? _fragmentManager;
  List<FloatingText> floatingTexts = [];

  int get wave => _waveManager.wave;
  double get difficulty => _waveManager.difficulty;
  bool get isBossWave => _waveManager.isBossWave;
  bool get isWaveInterstitial => _waveManager.isWaveInterstitial;
  double get waveTimer => _waveManager.waveTimer;

  String get comboRank {
    if (combo >= 50) return 'SSS';
    if (combo >= 30) return 'SS';
    if (combo >= 20) return 'S';
    if (combo >= 15) return 'A';
    if (combo >= 10) return 'B';
    if (combo >= 5) return 'C';
    return 'D';
  }

  Color get comboColor {
    if (combo >= 20) return GameColors.neonPink;
    if (combo >= 10) return GameColors.accent;
    return Colors.white70;
  }

  Vec2 cameraPos = Vec2.zero;
  double screenShake = 0.0;
  Vec2 shakeDir = Vec2.zero;

  Timer? _gameLoop;
  DateTime? _lastTick;

  final Random _random = Random();

  GameEngine() {
    _initPlayer();
  }

  void _initPlayer() {
    final maxLevel = settings?.maxIntegrityLevel ?? 0;
    final damageLevel = settings?.attackDamageLevel ?? 0;
    final magnetUnlocked = settings?.dataMagnetUnlocked ?? false;

    player = Player(
      pos: Vec2.zero,
      maxIntegrity: 4 + maxLevel,
      integrity: 4 + maxLevel,
    );
    player.damageMultiplier = 1.0 + (damageLevel * 0.1);
    player.dataMagnetUnlocked = magnetUnlocked;

    if (_fragmentManager != null) {
      final stats = _fragmentManager!.getAggregatedStats();
      player.moveSpeedBonus = stats['moveSpeed'] ?? 0.0;
      player.defenseBonus = stats['defense'] ?? 0.0;
      player.critChance = stats['critChance'] ?? 0.0;
    }
  }

  void startGame() {
    state = GameState.playing;
    _initPlayer();
    enemies.clear();
    projectiles.clear();
    expOrbs.clear();
    activeCorruptions.clear();
    score = 0;
    combo = 0;
    gameTime = 0.0;
    shakeDir = Vec2.zero;
    paused = false;

    _waveManager.reset();

    _lastTick = DateTime.now();
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) => _tick(),
    );
    notifyListeners();
  }

  void togglePause() {
    paused = !paused;
    notifyListeners();
  }

  double _gridOffset = 0.0;
  double get gridOffset => _gridOffset;

  double _bulletTimeIntensity = 0.0;
  double get bulletTimeIntensity => _bulletTimeIntensity;

  double _hitStopTimer = 0.0;

  void _tick() {
    if (state != GameState.playing) return;

    final now = DateTime.now();
    double dt = now.difference(_lastTick!).inMicroseconds / 1000000.0;
    _lastTick = now;

    if (paused) return;

    // Hit Stop Logic
    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
      return; // Pause update for juice
    }

    // Bullet Time Logic: Smoother transition
    if (!player.isDashing) {
      // Slow down time significantly when not dashing
      timeScale += (GameConstants.bulletTimeScale - timeScale) * 0.1;
      _bulletTimeIntensity += (1.0 - _bulletTimeIntensity) * 0.05;
    } else {
      // Normal time during dash
      timeScale += (1.0 - timeScale) * 0.2;
      _bulletTimeIntensity += (0.0 - _bulletTimeIntensity) * 0.1;
    }

    double scaledDt = dt * timeScale;
    gameTime += scaledDt;
    // difficulty = 1.0 + (gameTime / 90.0); // Difficulty now handled by WaveManager
    _gridOffset = (_gridOffset + 100 * scaledDt) % 200;

    // Update combo
    if (combo > 0) {
      comboTimer -= dt * timeScale;
      if (comboTimer <= 0) {
        combo = 0;
        notifyListeners();
      }
    }

    // Corruption Effects: Memory Leak (HP Drain)
    if (activeCorruptions.any((c) => c.type == CorruptionType.memoryLeak)) {
      if (gameTime % 1.0 < scaledDt) {
        // Roughly once per second
        player.integrity = max(1, player.integrity - 1);
        if (player.integrity <= 3) screenShake = 3.0;
      }
    }

    _updatePlayer(dt);
    _updateEnemies(scaledDt);
    _updateProjectiles(scaledDt);
    _updateExpOrbs(scaledDt);
    _updateParticles(scaledDt);
    _updateCamera(dt);

    _spawnEnemies(scaledDt);
    _checkCollisions();

    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) combo = 0;
    }

    if (screenShake > 0) {
      screenShake -= dt * 10;
      if (screenShake < 0) screenShake = 0;
    }

    notifyListeners();
  }

  void _updatePlayer(double dt) {
    double speedMult = settings?.customRules['speed_mult'] ?? 1.0;
    player.update(dt, speedMult: speedMult);

    // Shield logic
    if (player.shieldUnlocked) {
      if (player.shieldCooldown > 0) {
        player.shieldCooldown -= dt;
      } else if (!player.shieldActive) {
        player.shieldActive = true;
      }
    }

    // Overclock logic
    if (player.overclockTimer > 0) {
      player.overclockTimer -= dt;
    }

    // Trail management
    if (player.isDashing) {
      player.trails.add(
        PlayerTrail(
          pos: player.pos,
          life: 0.4,
          width: player.wideBladeUnlocked ? player.size * 3 : player.size,
        ),
      );
    }

    for (int i = player.trails.length - 1; i >= 0; i--) {
      player.trails[i].life -= dt * 3;
      if (player.trails[i].life <= 0) player.trails.removeAt(i);
    }

    if (player.integrity <= 0) {
      _gameOver();
    }
  }

  void _updateEnemies(double dt) {
    for (var enemy in enemies) {
      enemy.update(dt, player.pos, (pos, dir, speed, {isSniper = false}) {
        _spawnProjectile(pos, dir, speed, isSniper: isSniper);
      });
    }
    enemies.removeWhere((e) => !e.active);
  }

  void _updateProjectiles(double dt) {
    for (var p in projectiles) {
      p.update(dt);
    }
    projectiles.removeWhere((p) => !p.active);
  }

  void _updateExpOrbs(double dt) {
    for (var orb in expOrbs) {
      orb.update(dt, player.pos, player.dataMagnetUnlocked);
    }
    expOrbs.removeWhere((o) => !o.active);
  }

  void _updateParticles(double dt) {
    for (var p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  void _updateFloatingTexts(double dt) {
    for (var ft in floatingTexts) {
      ft.pos = Vec2(ft.pos.x, ft.pos.y + ft.velocityY * dt);
      ft.life -= dt;
    }
    floatingTexts.removeWhere((ft) => ft.life <= 0);
  }

  void _spawnExplosion(Vec2 pos, Color color, {int count = 10}) {
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 100.0 + _random.nextDouble() * 300.0;
      particles.add(
        Particle(
          pos: pos,
          vel: Vec2(cos(angle) * speed, sin(angle) * speed),
          life: 0.5 + _random.nextDouble() * 0.5,
          color: color,
          size: 2.0 + _random.nextDouble() * 3.0,
        ),
      );
    }
  }

  void _updateCamera(double dt) {
    final target = player.pos;
    cameraPos += (target - cameraPos) * (5.0 * dt);
  }

  void startBossRush() {
    state = GameState.playing;
    mode = GameMode.bossRush;
    _initPlayer();
    enemies.clear();
    projectiles.clear();
    expOrbs.clear();
    score = 0;

    _waveManager.reset(bossRush: true);

    gameTime = 0.0;
    _gameLoop?.cancel();
    _lastTick = DateTime.now();
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) => _tick(),
    );
    notifyListeners();
  }

  void _spawnEnemies(double dt) {
    _waveManager.update(dt);

    if (_waveManager.isWaveInterstitial) {
      if (_waveManager.checkWaveStart()) {
        if (wave % 5 == 0 && mode != GameMode.bossRush) {
          triggerCorruptionSelect();
          return;
        }

        _waveManager.startNextWave(isBossRush: mode == GameMode.bossRush);
        if (_waveManager.isBossWave) {
          screenShake = 2.0;
        }
      } else {
        return;
      }
    }

    if (_waveManager.isBossWave) {
      if (enemies.isEmpty && _waveManager.enemiesToSpawn > 0) {
        final bossType = _waveManager.getBossType();
        enemies.add(Enemy.spawn(player.pos, bossType, difficulty));
        _waveManager.enemiesToSpawn = 0;
      } else if (enemies.isEmpty && _waveManager.enemiesToSpawn <= 0) {
        _clearWave();
      }
      return;
    }

    if (_waveManager.enemiesToSpawn > 0 && enemies.length < 12 + wave) {
      double spawnRateMult = settings?.customRules['spawn_rate'] ?? 1.0;
      if (_random.nextDouble() < 0.05 * difficulty * spawnRateMult) {
        final type = _waveManager.getEnemyTypeForWave();
        enemies.add(Enemy.spawn(player.pos, type, difficulty));
        _waveManager.enemiesToSpawn--;
      }
    } else if (_waveManager.enemiesToSpawn <= 0 && enemies.isEmpty) {
      _clearWave();
    }
  }

  void triggerCorruptionSelect() {
    state = GameState.corruptionSelect;
    _gameLoop?.cancel();

    // Pick 3 random unique corruptions
    final all = List<Corruption>.from(Corruption.all);
    all.shuffle(_random);
    availableCorruptions = all.take(3).toList();
    notifyListeners();
  }

  void selectCorruption(Corruption corruption) {
    activeCorruptions.add(corruption);

    // Apply Immediate Effects if any (mostly stat changes handled in getters/updates)
    if (corruption.type == CorruptionType.glassCannon) {
      player.maxIntegrity = (player.maxIntegrity * 0.7).round();
      if (player.integrity > player.maxIntegrity)
        player.integrity = player.maxIntegrity;
      player.damageMultiplier += 0.4;
    } else if (corruption.type == CorruptionType.overclock) {
      player.corruptionAttackSpeedBonus += 0.3; // Stance-independent
    }

    // Resume Game
    state = GameState.playing;
    _lastTick = DateTime.now();
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) => _tick(),
    );

    // Continue with wave spawn logic
    _waveManager.startNextWave(isBossRush: mode == GameMode.bossRush);
    if (_waveManager.isBossWave) {
      screenShake = 2.0;
    }
    notifyListeners();
  }

  void _clearWave() {
    _waveManager.completeWave();
    // Heal player slightly on wave clear
    player.integrity = (player.integrity + 1).clamp(0, player.maxIntegrity);
  }

  void _spawnProjectile(
    Vec2 pos,
    Vec2 dir,
    double speed, {
    bool isSniper = false,
  }) {
    projectiles.add(
      Projectile(
        pos: pos,
        vel: dir * speed,
        size: isSniper ? 4 : 5,
        life: 3.0,
        isSniper: isSniper,
        color: isSniper ? Colors.red : const Color(0xFFFF004D),
      ),
    );
  }

  void _checkCollisions() {
    // Player Dash Attack
    if (player.isDashing) {
      for (var enemy in enemies) {
        if (enemy.type == EnemyType.dataWorm) {
          // Check segments for Data Worm
          for (int i = enemy.segments.length - 1; i >= 0; i--) {
            final segPos = enemy.segments[i];
            final d = Vec2.distPointToLine(segPos, player.lastPos, player.pos);
            if (d < enemy.size + (player.wideBladeUnlocked ? 40 : 20)) {
              _spawnExplosion(segPos, enemy.color, count: 10);
              enemy.segments.removeAt(i);
              score += 50;
              combo++;
              comboTimer = 2.0;
            }
          }
          if (enemy.segments.isEmpty) _killEnemy(enemy, isCritical: true);
        } else {
          final d = Vec2.distPointToLine(enemy.pos, player.lastPos, player.pos);
          if (d < enemy.size + (player.wideBladeUnlocked ? 40 : 20)) {
            _killEnemy(enemy, isCritical: true);
            _hitStopTimer = 0.05; // Hit stop for impact
          }
        }
      }

      // Ghost Mode: Dashing through bullets deactivates them
      for (var p in projectiles) {
        if (!p.isPlayer) {
          final d = Vec2.distPointToLine(p.pos, player.lastPos, player.pos);
          if (d < 30) {
            if (player.dashDuration < 0.2) {
              // Just Defend (Perfect Parry)
              p.isPlayer = true;
              p.color = GameColors.playerGlitch;
              p.vel = p.vel * -2.0; // Reflect back with speed
              p.life = 2.0;
              score += 200;
              _spawnExplosion(p.pos, GameColors.playerGlitch, count: 5);
              if (settings?.hapticEnabled ?? false)
                HapticFeedback.heavyImpact();
            } else {
              // Standard Ghost Break
              p.active = false;
              score += 50;
              if (settings?.hapticEnabled ?? false)
                HapticFeedback.lightImpact();
            }
            _hitStopTimer = 0.02; // Tiny stop for impact feel
          }
        }
      }
    } else {
      // Player hit by enemy or projectile
      for (var enemy in enemies) {
        bool hit = false;
        if (enemy.type == EnemyType.dataWorm) {
          // Check head
          if (Vec2.distance(player.pos, enemy.pos) < enemy.size + player.size)
            hit = true;
          // Check segments
          if (!hit) {
            for (final seg in enemy.segments) {
              if (Vec2.distance(player.pos, seg) < enemy.size + player.size) {
                hit = true;
                break;
              }
            }
          }
        } else {
          final d = Vec2.distance(player.pos, enemy.pos);
          if (d < enemy.size + player.size) hit = true;
        }

        if (hit) {
          _playerHit(
            1,
            source: enemy.type.toString().split('.').last.toUpperCase(),
            hitDir: player.pos - enemy.pos,
          );
          // Don't kill boss/worm/mirrorRonin on touch, just damage player
          if (enemy.type != EnemyType.boss &&
              enemy.type != EnemyType.dataWorm &&
              enemy.type != EnemyType.mirrorRonin) {
            enemy.active = false;
          }
        }
      }
      for (var p in projectiles) {
        if (!p.isPlayer) {
          final d = Vec2.distance(player.pos, p.pos);
          if (d < p.size + player.size) {
            _playerHit(
              1,
              source: p.isSniper ? 'SNIPER_ROUND' : 'PROJECTILE',
              hitDir: p.vel,
            );
            p.active = false;
          }
        }
      }
    }

    // Player Projectile vs Enemy
    for (var p in projectiles) {
      if (p.isPlayer) {
        for (var enemy in enemies) {
          if (enemy.type == EnemyType.dataWorm) {
            // Head is invulnerable
            bool hitSegment = false;
            for (int i = enemy.segments.length - 1; i >= 0; i--) {
              if (Vec2.distance(p.pos, enemy.segments[i]) <
                  enemy.size + p.size) {
                enemy.segments.removeAt(i);
                _spawnExplosion(enemy.segments[i], enemy.color, count: 5);
                hitSegment = true;
                p.active = false;
                score += 10;
                break; // One segment per bullet
              }
            }
            if (hitSegment) {
              // Trigger haptic/visual feedback
              if (settings?.hapticEnabled ?? false) {
                HapticFeedback.lightImpact();
              }
              if (enemy.segments.isEmpty) _killEnemy(enemy);
            }
          } else {
            final d = Vec2.distance(p.pos, enemy.pos);
            if (d < enemy.size + p.size) {
              // Apply Stance Damage Multiplier
              bool isCrit = _random.nextDouble() < player.critChance;
              double dmg =
                  1.0 *
                  player.damageMultiplier *
                  player.stanceDamageMulti *
                  (isCrit ? 2.0 : 1.0);
              enemy.hp -= dmg;
              p.active = false;
              if (enemy.hp <= 0) _killEnemy(enemy, isCritical: isCrit);
            }
          }
        }
      }
    }

    // Player vs ExpOrb
    for (var orb in expOrbs) {
      final d = Vec2.distance(player.pos, orb.pos);
      if (d < 20) {
        orb.active = false;
        if (player.gainXp(orb.value)) {
          // Level up logic handled in gainXp, but we might want to pause game for upgrades
          state = GameState.upgrades;
          _gameLoop?.cancel();
        }
      }
    }
  }

  void _killEnemy(Enemy enemy, {bool isCritical = false}) {
    enemy.active = false;

    // Score Multiplier (Glitch Vision)
    double scoreMulti = 1.0;
    if (activeCorruptions.any((c) => c.type == CorruptionType.glitchVision))
      scoreMulti += 0.5;

    score += (100 * difficulty * (isCritical ? 1.5 : 1.0) * scoreMulti).toInt();
    combo++;
    comboTimer = 2.0;
    screenShake = enemy.isElite ? 1.0 : 0.5;

    // Heal on Kill (Memory Leak)
    if (activeCorruptions.any((c) => c.type == CorruptionType.memoryLeak)) {
      player.integrity = min(player.maxIntegrity, player.integrity + 1);
    }

    if (player.overclockUnlocked) {
      player.overclockTimer = 3.0;
    }

    _spawnExplosion(enemy.pos, enemy.color, count: enemy.isElite ? 30 : 15);
    _spawnExplosion(enemy.pos, GameColors.playerGlitch, count: 5);

    // Splitter logic
    if (enemy.type == EnemyType.splitter) {
      for (int i = 0; i < (enemy.isElite ? 5 : 3); i++) {
        final angle = _random.nextDouble() * pi * 2;
        final mini = Enemy(
          pos: enemy.pos + Vec2(cos(angle) * 20, sin(angle) * 20),
          type: EnemyType.mini,
          hp: 1.0,
          maxHp: 1.0,
          speed: 220.0,
          size: 10.0,
          color: Colors.purpleAccent,
        );
        enemies.add(mini);
      }
    }

    // Spawn Exp Orbs: Elite drops more
    final orbCount = enemy.isElite ? 3 : 1;
    for (int i = 0; i < orbCount; i++) {
      expOrbs.add(
        ExpOrb(
          pos:
              enemy.pos +
              Vec2(
                _random.nextDouble() * 20 - 10,
                _random.nextDouble() * 20 - 10,
              ),
          value: (50 * difficulty).toInt(),
        ),
      );
    }

    // Glitch Pulse
    if (combo >= GameConstants.glitchPulseCombo) {
      _triggerGlitchPulse();
    }

    if (enemy.type == EnemyType.boss) {
      settings?.addDataFragments(50); // Boss gives more fragments
    }

    // Fragment Drop Logic
    if (_fragmentManager != null) {
      final dropId = _fragmentManager!.checkDrop(enemy.type, combo);
      if (dropId != null) {
        settings?.updateFragmentInventory(dropId, 1);

        final fragment = FragmentDatabase.allFragments.firstWhere(
          (f) => f.id == dropId,
          orElse: () => FragmentDatabase.allFragments.first,
        );

        Color rarityColor = Colors.white;
        if (fragment.rarity == FragmentRarity.uncommon)
          rarityColor = Colors.greenAccent;
        if (fragment.rarity == FragmentRarity.rare) rarityColor = Colors.blue;
        if (fragment.rarity == FragmentRarity.legendary)
          rarityColor = Colors.orange;

        floatingTexts.add(
          FloatingText(
            pos: enemy.pos,
            text: '[${fragment.name}]',
            color: rarityColor,
            life: 2.0,
          ),
        );
      }
    }
  }

  void _triggerGlitchPulse() {
    // Clear all enemy projectiles nearby
    for (var p in projectiles) {
      if (!p.isPlayer) {
        final d = Vec2.distance(player.pos, p.pos);
        if (d < 300) p.active = false;
      }
    }
    screenShake = 1.0;
  }

  String killerName = 'UNKNOWN_SYSTEM_FAILURE';

  void _playerHit(int damage, {String source = 'PROJECTILE', Vec2? hitDir}) {
    if (settings?.hapticEnabled ?? false) HapticFeedback.heavyImpact();

    if (hitDir != null) {
      shakeDir = hitDir.normalized;
    }

    // LogicGate Mod: Defense Chance
    if (player.defenseBonus > 0) {
      if (_random.nextDouble() < player.defenseBonus) {
        floatingTexts.add(
          FloatingText(
            pos: player.pos,
            text: 'BLOCKED',
            color: Colors.blueAccent,
            life: 1.0,
            velocityY: -100,
          ),
        );
        return;
      }
    }

    // Just Defend / Parry Logic
    if (player.parryWindow > 0) {
      player.parryWindow = 0.0;
      screenShake = 2.0;
      _spawnExplosion(player.pos, Colors.white, count: 40);
      _triggerGlitchPulse();
      score += 500;

      // Push back nearby enemies
      for (var e in enemies) {
        if (Vec2.distance(player.pos, e.pos) < 200) {
          if (e.type != EnemyType.boss && e.type != EnemyType.dataWorm) {
            final away = (e.pos - player.pos).normalized;
            e.pos += away * 100;
          }
        }
      }
      return;
    }

    if (player.shieldActive) {
      player.shieldActive = false;
      player.shieldCooldown = 30.0;
      screenShake = 0.5;
      _spawnExplosion(player.pos, Colors.cyan, count: 20);
      return;
    }

    player.integrity -= damage;
    killerName = source;
    screenShake = 1.5;
    combo = 0;
    if (player.integrity <= 0) {
      _gameOver();
    }
  }

  void _gameOver() {
    state = GameState.gameOver;
    _gameLoop?.cancel();

    final fragmentsEarned = (score / 1000).toInt();

    // Sync with global settings
    if (settings != null) {
      settings!.updateHighScore(score);
      settings!.addDataFragments(fragmentsEarned);
    }

    notifyListeners();
  }

  void handleTap(Offset localPosition, Size screenSize) {
    if (state == GameState.menu || state == GameState.gameOver) {
      startGame();
      return;
    }

    if (state == GameState.playing) {
      // Dash logic: release handles dash, but we need drag start
    }
  }

  void handleDragStart(Offset localPosition) {
    if (state == GameState.playing) {
      // logic for drag
    }
  }

  void handleDragUpdate(Offset localPosition) {
    // logic for drag
  }

  void handleDragEnd(Offset dragStart, Offset dragEnd) {
    if (state == GameState.playing && !player.isDashing) {
      final diff = Vec2(dragEnd.dx - dragStart.dx, dragEnd.dy - dragStart.dy);
      if (diff.magnitude > 10) {
        // Apply stance multipliers
        final speed = GameConstants.dashSpeed * player.dashRangeMulti;

        player.isDashing = true;
        player.dashDuration = 0.0;
        player.vel = diff.normalized * speed;
        player.parryWindow = 0.25; // Trigger Just Defend window

        if (player.swordBeamUnlocked) {
          int count = player.stance == GlitchStance.dual ? 3 : 1;
          double spread = player.stance == GlitchStance.dual ? 0.3 : 0.0;

          for (int i = 0; i < count; i++) {
            double angleOffset = (i - (count - 1) / 2) * spread;
            double c = cos(angleOffset);
            double s = sin(angleOffset);
            Vec2 dir = diff.normalized;
            Vec2 beamDir = Vec2(dir.x * c - dir.y * s, dir.x * s + dir.y * c);

            _spawnPlayerProjectile(player.pos, beamDir);
          }
        }
      }
    }
  }

  void switchStance() {
    if (state == GameState.playing) {
      player.switchStance();
      notifyListeners();
    }
  }

  void _spawnPlayerProjectile(Vec2 pos, Vec2 dir) {
    projectiles.add(
      Projectile(
        pos: pos,
        vel: dir * 1400,
        size: 15,
        life: 0.7,
        isPlayer: true,
        color: GameColors.playerProjectile,
      ),
    );
  }

  List<UpgradeOption> getUpgradeOptions() {
    final all = [
      UpgradeOption(
        title: 'SWORD_BEAM',
        description: 'DASH EMITS DESTRUCTIVE DATA WAVES',
        onApply: () => player.swordBeamUnlocked = true,
      ),
      UpgradeOption(
        title: 'WIDE_BLADE',
        description: 'INCREASE SLASH AREA OF EFFECT',
        onApply: () => player.wideBladeUnlocked = true,
      ),
      UpgradeOption(
        title: 'DATA_MAGNET',
        description: 'ATTRACT EXP ORBS FROM DISTANCE',
        onApply: () => player.dataMagnetUnlocked = true,
      ),
      UpgradeOption(
        title: 'ENERGY_SHIELD',
        description: 'AUTOMATICALLY BLOCKS ONE HIT (30s COOLDOWN)',
        onApply: () => player.shieldUnlocked = true,
      ),
      UpgradeOption(
        title: 'OVERCLOCK',
        description: 'KILLS INCREASE DASH SPEED TEMPORARILY',
        onApply: () => player.overclockUnlocked = true,
      ),
      UpgradeOption(
        title: 'INTEGRITY_REPAIR',
        description: 'RESTORE 30% CHASSIS INTEGRITY',
        onApply: () =>
            player.integrity = (player.integrity + player.maxIntegrity * 0.3)
                .clamp(0, player.maxIntegrity.toDouble())
                .toInt(),
      ),
    ];
    all.shuffle();
    return all.take(3).toList();
  }

  void applyUpgrade(UpgradeOption upgrade) {
    upgrade.onApply();
    state = GameState.playing;
    _lastTick = DateTime.now();
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) => _tick(),
    );
    notifyListeners();
  }
}
