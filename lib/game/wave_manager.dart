import 'dart:math';
import '../models/enemy.dart';
import '../models/level_config.dart';

class WaveManager {
  int wave = 1;
  double waveTimer = 0.0;
  bool isWaveInterstitial = false;
  bool isBossWave = false;
  int enemiesToSpawn = 0;
  double difficulty = 1.0;
  
  final Random _random = Random();

  // Configuration for procedural generation
  final List<WaveSpawnRule> _spawnRules = [
    const WaveSpawnRule(minWave: 1, enemies: [EnemyType.seeker]),
    const WaveSpawnRule(minWave: 2, enemies: [EnemyType.seeker, EnemyType.shooter]),
    const WaveSpawnRule(minWave: 3, enemies: [EnemyType.mine, EnemyType.teleporter]),
    const WaveSpawnRule(minWave: 4, enemies: [EnemyType.dasher]),
    const WaveSpawnRule(minWave: 5, enemies: [EnemyType.orbiter]),
    const WaveSpawnRule(minWave: 6, enemies: [EnemyType.sniper]),
    const WaveSpawnRule(minWave: 8, enemies: [EnemyType.splitter]),
  ];

  void reset({bool bossRush = false}) {
    wave = 1;
    difficulty = bossRush ? 2.0 : 1.0;
    isWaveInterstitial = true;
    waveTimer = 3.0;
    enemiesToSpawn = bossRush ? 1 : 10;
    isBossWave = bossRush;
  }

  void update(double dt) {
    if (isWaveInterstitial) {
      waveTimer -= dt;
    }
  }

  /// Returns true if the wave interstitial period just ended
  bool checkWaveStart() {
    if (isWaveInterstitial && waveTimer <= 0) {
      isWaveInterstitial = false;
      return true;
    }
    return false;
  }

  void startNextWave({bool isBossRush = false}) {
    if (isBossRush) {
      enemiesToSpawn = 1;
      isBossWave = true;
    } else {
      enemiesToSpawn = 5 + (wave * 5);
      isBossWave = (wave % 5 == 0);
      if (isBossWave) {
        enemiesToSpawn = 1; // Just the boss
      }
    }
  }

  void completeWave() {
    wave++;
    difficulty += 0.2;
    isWaveInterstitial = true;
    waveTimer = 5.0;
    isBossWave = false;
  }

  EnemyType getEnemyTypeForWave() {
    // Collect all allowed enemies for current wave
    List<EnemyType> available = [];
    for (var rule in _spawnRules) {
      if (wave >= rule.minWave) {
        available.addAll(rule.enemies);
      }
    }
    
    // Fallback
    if (available.isEmpty) return EnemyType.seeker;

    return available[_random.nextInt(available.length)];
  }

  EnemyType getBossType() {
    final r = _random.nextDouble();
    return r < 0.33
        ? EnemyType.boss
        : (r < 0.66 ? EnemyType.dataWorm : EnemyType.mirrorRonin);
  }
}
