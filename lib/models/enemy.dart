import 'dart:math';
import 'package:flutter/material.dart';
import '../core/vector2.dart';

enum EnemyType {
  seeker,
  sniper,
  mine,
  dasher,
  splitter,
  mini,
  shooter,
  boss,
  teleporter,
  orbiter,
  dataWorm,
  mirrorRonin,
}

class Enemy {
  Vec2 pos;
  EnemyType type;
  double hp;
  double maxHp;
  double speed;
  double size;
  Color color;
  bool isElite;
  bool active = true;
  String state = 'normal';
  double stateTimer = 0.0;
  Vec2? aimDir;
  double chromaticOffset = 0.0;

  // Data Worm specific
  List<Vec2> segments = [];
  static const double segmentSpacing = 24.0;

  Enemy({
    required this.pos,
    required this.type,
    required this.hp,
    required this.maxHp,
    required this.speed,
    required this.size,
    required this.color,
    this.isElite = false,
  });

  factory Enemy.spawn(Vec2 playerPos, EnemyType type, double difficulty) {
    final random = Random();
    final angle = random.nextDouble() * pi * 2;
    final dist = 700.0 + random.nextDouble() * 400.0;
    final pos = playerPos + Vec2(cos(angle) * dist, sin(angle) * dist);

    double baseHp = 1.0;
    double baseSpeed = 100.0;
    double size = 18.0;
    Color color = const Color(0xFFFFCC00);
    bool isElite = false;

    if (type != EnemyType.boss &&
        type != EnemyType.dataWorm &&
        type != EnemyType.mine &&
        random.nextDouble() < min(0.2, (difficulty - 1) * 0.05)) {
      isElite = true;
    }

    switch (type) {
      case EnemyType.boss:
        size = 65;
        baseSpeed = 45;
        color = Colors.red;
        baseHp = 40;
        break;
      case EnemyType.dataWorm:
        size = 30;
        baseSpeed = 70;
        color = Colors.greenAccent;
        baseHp = 10; // HP = segment count
        break;
      case EnemyType.mirrorRonin:
        size = 22; // Player size is usually small, keep it similar
        baseSpeed = 180; // Fast like player
        color = const Color(0xFF222222); // Dark/Shadow
        baseHp = 25;
        break;
      case EnemyType.sniper:
        size = 22;
        baseSpeed = 35;
        color = Colors.white;
        baseHp = 3;
        break;
      case EnemyType.mine:
        size = 15;
        baseSpeed = 0;
        color = Colors.orange;
        baseHp = 1;
        break;
      case EnemyType.dasher:
        size = 20;
        baseSpeed = 0;
        color = Colors.orangeAccent;
        baseHp = 2;
        break;
      case EnemyType.teleporter:
        size = 18;
        baseSpeed = 0; // Moves via teleport
        color = Colors.purpleAccent;
        baseHp = 2;
        break;
      case EnemyType.orbiter:
        size = 16;
        baseSpeed = 160; // Fast orbit
        color = Colors.cyanAccent;
        baseHp = 2;
        break;
      case EnemyType.splitter:
        size = 25;
        baseSpeed = 65;
        color = Colors.purpleAccent;
        baseHp = 2;
        break;
      case EnemyType.mini:
        size = 10;
        baseSpeed = 220;
        color = Colors.purpleAccent;
        baseHp = 1;
        break;
      case EnemyType.shooter:
        size = 20;
        baseSpeed = 55;
        color = const Color(0xFFFF004D);
        baseHp = 2;
        break;
      case EnemyType.mirrorRonin:
        size = 24;
        baseSpeed = 150;
        color = Colors.white;
        baseHp = 30; // Boss HP
        break;
      case EnemyType.seeker:
      default:
        size = 18;
        baseSpeed = 110;
        color = const Color(0xFFFFCC00);
        baseHp = 1.5;
        break;
    }

    double maxHp = baseHp * difficulty;
    double speed = baseSpeed * (1 + (difficulty - 1) * 0.15);

    if (isElite) {
      maxHp *= 3.0;
      size *= 1.4;
      color = const Color(0xFFFFD700);
    }

    final enemy = Enemy(
      pos: pos,
      type: type,
      hp: maxHp,
      maxHp: maxHp,
      speed: speed,
      size: size,
      color: color,
      isElite: isElite,
    );

    if (type == EnemyType.dataWorm) {
      // Initialize segments trailing behind
      for (int i = 0; i < 10; i++) {
        // 10 segments
        enemy.segments.add(pos - Vec2(1, 0) * (Enemy.segmentSpacing * (i + 1)));
      }
    }

    return enemy;
  }

  bool isEnraged = false;

  void update(
    double dt,
    Vec2 playerPos,
    Function(Vec2, Vec2, double, {bool isSniper}) spawnProjectile,
  ) {
    if (!active) return;

    if (chromaticOffset > 0) {
      chromaticOffset = max(0, chromaticOffset - dt * 25);
    }

    final distToPlayer = Vec2.distance(pos, playerPos);

    switch (type) {
      case EnemyType.dataWorm:
        // Head movement (Wander + Seek mix)
        stateTimer -= dt;
        if (stateTimer <= 0) {
          // Change direction occasionally
          stateTimer = 1.0 + Random().nextDouble() * 2.0;
          final toPlayer = (playerPos - pos).normalized;
          // Mix direct seeking with some perpendicular movement for "snake" feel
          final perp = Vec2(-toPlayer.y, toPlayer.x);
          aimDir = (toPlayer + perp * (Random().nextDouble() - 0.5)).normalized;
        }

        // Always move forward
        aimDir ??= (playerPos - pos).normalized;

        // Smooth turn towards player if far
        final idealDir = (playerPos - pos).normalized;
        // Manual lerp: v1 + (v2 - v1) * t
        aimDir = (aimDir! + (idealDir - aimDir!) * (dt * 2.0)).normalized;

        pos += aimDir! * (speed * dt);

        // Update segments (Drag kinematics)
        if (segments.isNotEmpty) {
          Vec2 target = pos;
          for (int i = 0; i < segments.length; i++) {
            Vec2 current = segments[i];
            Vec2 toTarget = target - current;
            if (toTarget.magnitude > segmentSpacing) {
              segments[i] = target - toTarget.normalized * segmentSpacing;
            }
            target = segments[i];
          }
        }

        // If no segments left, die
        if (segments.isEmpty) {
          hp = 0; // Triggers death in engine
        }
        break;
      case EnemyType.sniper:
        if (distToPlayer < 500) {
          final away = (pos - playerPos).normalized;
          pos += away * (60 * dt);
        }
        if (state == 'aim') {
          aimDir = (playerPos - pos).normalized;
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'fire';
            stateTimer = 0.5;
            spawnProjectile(pos, aimDir!, 2000, isSniper: true);
          }
        } else {
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'aim';
            stateTimer = 2.0;
          }
        }
        break;
      case EnemyType.dasher:
        if (state == 'charge') {
          stateTimer -= dt;
          aimDir = (playerPos - pos).normalized;
          if (stateTimer <= 0) {
            state = 'dash';
            stateTimer = 0.4;
          }
        } else if (state == 'dash') {
          pos += aimDir! * (800 * dt);
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'cooldown';
            stateTimer = 1.0;
          }
        } else {
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'charge';
            stateTimer = 1.0;
          }
        }
        break;
      case EnemyType.boss:
        // Boss Phase Logic
        if (!isEnraged && hp < maxHp * 0.5) {
          isEnraged = true;
          color = const Color(0xFFFF0000); // Deep red
          speed *= 1.5;
        }

        final dir = (playerPos - pos).normalized;
        pos += dir * (speed * dt);
        stateTimer -= dt;

        // Attack pattern
        double attackCooldown = isEnraged ? 0.6 : 1.2;
        if (stateTimer <= 0) {
          stateTimer = attackCooldown;
          int projectileCount = isEnraged ? 16 : 8;
          double speedMulti = isEnraged ? 1.5 : 1.0;

          for (int i = 0; i < projectileCount; i++) {
            final angle =
                (pi * 2 / projectileCount) * i +
                (DateTime.now().millisecondsSinceEpoch /
                    (isEnraged ? 200.0 : 400.0));
            spawnProjectile(
              pos,
              Vec2(cos(angle), sin(angle)),
              180 * speedMulti,
            );
          }
        }
        break;
      case EnemyType.mirrorRonin:
        // AI: Aggressive Stalker
        if (state == 'dash') {
          // Executing dash
          pos += aimDir! * (800 * dt);
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'cooldown';
            stateTimer = 1.0;
          }
        } else if (state == 'charge') {
          // Freezing before dash
          stateTimer -= dt;
          // Track player perfectly during charge until last moment
          if (stateTimer > 0.1) {
            aimDir = (playerPos - pos).normalized;
          }
          if (stateTimer <= 0) {
            state = 'dash';
            stateTimer = 0.3; // Short dash duration
          }
        } else if (state == 'cooldown') {
          // Retreat or strafe
          final away = (pos - playerPos).normalized;
          pos += away * (speed * 0.5 * dt);
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'stalk';
          }
        } else {
          // Stalking
          final dir = (playerPos - pos).normalized;
          pos += dir * (speed * dt);

          if (distToPlayer < 300) {
            state = 'charge';
            stateTimer = 0.5;
            aimDir = dir;
          }
        }
        break;
      case EnemyType.shooter:
        if (distToPlayer < 300) {
          final away = (pos - playerPos).normalized;
          pos += away * (speed * dt);
        } else if (distToPlayer > 500) {
          final dir = (playerPos - pos).normalized;
          pos += dir * (speed * dt);
        }
        stateTimer -= dt;
        if (stateTimer <= 0 && distToPlayer < 800) {
          stateTimer = 2.0;
          spawnProjectile(pos, (playerPos - pos).normalized, 300);
        }
        break;
      case EnemyType.mine:
        // Mines don't move
        break;
      case EnemyType.splitter:
        final dir = (playerPos - pos).normalized;
        pos += dir * (speed * dt);
        break;
      case EnemyType.teleporter:
        if (state == 'vanish') {
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'reappear';
            stateTimer = 0.5; // Reappear animation time
            // Teleport near player
            final angle = Random().nextDouble() * pi * 2;
            final dist = 150.0 + Random().nextDouble() * 100.0;
            pos = playerPos + Vec2(cos(angle) * dist, sin(angle) * dist);
          }
        } else if (state == 'reappear') {
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'chase';
            stateTimer = 2.0 + Random().nextDouble() * 2.0;
          }
        } else {
          // Chase
          final dir = (playerPos - pos).normalized;
          pos += dir * (speed * dt);
          stateTimer -= dt;
          if (stateTimer <= 0) {
            state = 'vanish';
            stateTimer = 1.0;
          }
        }
        break;
      case EnemyType.orbiter:
        final dist = Vec2.distance(pos, playerPos);
        final toPlayer = (playerPos - pos).normalized;

        // Orbit logic
        if (dist > 300) {
          pos += toPlayer * (speed * dt);
        } else if (dist < 200) {
          pos -= toPlayer * (speed * dt);
        }

        // Strafe
        final strafeDir = Vec2(-toPlayer.y, toPlayer.x); // Perpendicular
        pos += strafeDir * (speed * 0.5 * dt);

        // Fire
        stateTimer -= dt;
        if (stateTimer <= 0) {
          stateTimer = 2.5;
          spawnProjectile(pos, toPlayer, 250);
        }
        break;
      case EnemyType.mini:
      case EnemyType.seeker:
      default:
        final dir = (playerPos - pos).normalized;
        pos += dir * (speed * dt);
    }
  }
}
