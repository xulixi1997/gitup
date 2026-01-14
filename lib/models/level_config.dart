import '../models/enemy.dart';

class LevelConfig {
  final int waveNumber;
  final int enemyCount;
  final List<EnemyType> allowedEnemies;
  final double difficultyMultiplier;
  final bool isBossWave;
  final EnemyType? bossType;

  const LevelConfig({
    required this.waveNumber,
    required this.enemyCount,
    required this.allowedEnemies,
    this.difficultyMultiplier = 1.0,
    this.isBossWave = false,
    this.bossType,
  });
}

class WaveSpawnRule {
  final int minWave;
  final List<EnemyType> enemies;
  final double probability;

  const WaveSpawnRule({
    required this.minWave,
    required this.enemies,
    this.probability = 1.0,
  });
}
