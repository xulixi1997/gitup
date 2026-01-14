import 'dart:math';
import 'package:flutter/material.dart';
import '../core/vector2.dart';
import '../core/constants.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/projectile.dart';
import '../models/exp_orb.dart';
import 'game_engine.dart';

class GamePainter extends CustomPainter {
  final GameEngine engine;
  final Random _random = Random();

  GamePainter(this.engine) : super(repaint: engine);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background & Dynamic Grid
    _drawBackground(canvas, size);

    final center = Offset(size.width / 2, size.height / 2);

    // Apply Screen Shake
    if (engine.screenShake > 0) {
      if (engine.shakeDir.x != 0 || engine.shakeDir.y != 0) {
        final time = DateTime.now().millisecondsSinceEpoch / 20.0;
        final offset = sin(time) * 15 * engine.screenShake;
        canvas.translate(
          engine.shakeDir.x * offset,
          engine.shakeDir.y * offset,
        );
      } else {
        canvas.translate(
          (_random.nextDouble() - 0.5) * 20 * engine.screenShake,
          (_random.nextDouble() - 0.5) * 20 * engine.screenShake,
        );
      }
    }

    // Chromatic Aberration during bullet time or high shake
    if (engine.bulletTimeIntensity > 0.2 || engine.screenShake > 1.0) {
      _drawGlitchOverlays(canvas, size);
    }

    // Save camera transform
    canvas.save();
    canvas.translate(
      center.dx - engine.cameraPos.x,
      center.dy - engine.cameraPos.y,
    );

    _drawExpOrbs(canvas);
    _drawParticles(canvas);
    _drawFloatingTexts(canvas);
    _drawProjectiles(canvas);
    _drawEnemies(canvas);
    _drawPlayer(canvas);

    canvas.restore();

    // CRT Scanlines Overlay
    _drawScanlines(canvas, size);

    // UI elements (not affected by camera)
    _drawHUD(canvas, size);
  }

  void _drawScanlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Subtle radial gradient for vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
        stops: const [0.6, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = GameColors.background);

    // Dynamic Grid
    // Grid color shift based on difficulty: Blue -> Purple -> Red
    final dangerRatio = (engine.difficulty - 1.0).clamp(0.0, 4.0) / 4.0;
    final gridColor = Color.lerp(
      Colors.blue.withOpacity(0.1 + engine.bulletTimeIntensity * 0.2),
      Colors.red.withOpacity(0.1 + engine.bulletTimeIntensity * 0.2),
      dangerRatio,
    )!;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const gridSize = 100.0;
    final cameraOffset = engine.cameraPos;
    final startX = -(cameraOffset.x % gridSize);
    final startY = -(cameraOffset.y % gridSize);

    // Vertical lines
    for (double x = startX; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Horizontal lines
    for (double y = startY; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Boss Wave Warning Glow
    if (engine.isBossWave) {
      final rect = Offset.zero & size;
      final opacity =
          0.08 * (sin(DateTime.now().millisecondsSinceEpoch / 200).abs());
      canvas.drawRect(
        rect,
        Paint()..color = GameColors.boss.withOpacity(opacity),
      );
    }
  }

  void _drawGlitchOverlays(Canvas canvas, Size size) {
    // Simple chromatic aberration simulation by drawing colored rectangles with low opacity
    final intensity = engine.bulletTimeIntensity.clamp(0.0, 1.0);
    if (intensity > 0.1) {
      final cyanPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.05 * intensity);
      final magentaPaint = Paint()
        ..color = const Color(0xFFFF00FF).withOpacity(0.05 * intensity);

      canvas.drawRect(
        Rect.fromLTWH(2 * intensity, 0, size.width, size.height),
        cyanPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(-2 * intensity, 0, size.width, size.height),
        magentaPaint,
      );
    }

    // Screen flash on high shake
    if (engine.screenShake > 1.5) {
      final flashOpacity = (engine.screenShake / 5.0).clamp(0.0, 0.15);
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withOpacity(flashOpacity),
      );
    }
  }

  void _drawPlayer(Canvas canvas) {
    final player = engine.player;
    final paint = Paint()..color = GameColors.player;

    // Draw Trails
    for (var trail in player.trails) {
      final trailPaint = Paint()
        ..color = GameColors.playerGlitch.withOpacity(
          trail.life.clamp(0.0, 1.0),
        )
        ..strokeWidth = trail.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // We need at least two points for a line, but here we just draw small segments or dots
      canvas.drawCircle(
        Offset(trail.pos.x, trail.pos.y),
        trail.width / 2,
        trailPaint,
      );
    }

    // Draw Glitch Effect
    final glitchOffset =
        (sin(DateTime.now().millisecondsSinceEpoch / 50) * 5 * engine.timeScale)
            .abs();

    final bodyPaint = Paint()..style = PaintingStyle.fill;

    // Cyan glitch
    bodyPaint.color = GameColors.playerGlitch.withOpacity(0.6);
    _drawPlayerShape(
      canvas,
      player.pos.x + glitchOffset,
      player.pos.y,
      player.size,
      bodyPaint,
    );

    // Magenta/Red glitch
    bodyPaint.color = const Color(0xFFFF00FF).withOpacity(0.6);
    _drawPlayerShape(
      canvas,
      player.pos.x - glitchOffset,
      player.pos.y,
      player.size,
      bodyPaint,
    );

    // Main body
    bodyPaint.color = GameColors.player;
    _drawPlayerShape(
      canvas,
      player.pos.x,
      player.pos.y,
      player.size,
      bodyPaint,
    );
  }

  void _drawPlayerShape(
    Canvas canvas,
    double x,
    double y,
    double size,
    Paint paint,
  ) {
    final player = engine.player;
    final path = Path();

    switch (player.stance) {
      case GlitchStance.katana:
        // Standard Triangle
        path.moveTo(x, y - size);
        path.lineTo(x + size, y + size);
        path.lineTo(x, y + size / 2);
        path.lineTo(x - size, y + size);
        break;
      case GlitchStance.axe:
        // Heavier, wider shape
        path.moveTo(x, y - size * 0.8);
        path.lineTo(x + size * 1.2, y + size * 0.8);
        path.lineTo(x, y + size * 1.2);
        path.lineTo(x - size * 1.2, y + size * 0.8);
        break;
      case GlitchStance.dual:
        // Split shape (Two smaller triangles)
        path.moveTo(x - size * 0.5, y - size);
        path.lineTo(x, y + size);
        path.lineTo(x - size, y + size);
        path.close();

        path.moveTo(x + size * 0.5, y - size);
        path.lineTo(x + size, y + size);
        path.lineTo(x, y + size);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawEnemies(Canvas canvas) {
    for (var enemy in engine.enemies) {
      final glitchOffset =
          (sin(DateTime.now().millisecondsSinceEpoch / 100) * 3).abs() +
          enemy.chromaticOffset;

      final paint = Paint()..style = PaintingStyle.fill;

      // Charge line for Dasher
      if (enemy.type == EnemyType.dasher &&
          enemy.state == 'charge' &&
          enemy.aimDir != null) {
        final chargePaint = Paint()
          ..color = enemy.color.withOpacity(0.3)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(enemy.pos.x, enemy.pos.y),
          Offset(
            enemy.pos.x + enemy.aimDir!.x * 60,
            enemy.pos.y + enemy.aimDir!.y * 60,
          ),
          chargePaint,
        );
      }

      // Elite Aura
      if (enemy.isElite) {
        canvas.save();
        canvas.translate(enemy.pos.x, enemy.pos.y);
        canvas.rotate(DateTime.now().millisecondsSinceEpoch / 200);
        final auraPaint = Paint()
          ..color = GameColors.elite.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: enemy.size * 2.4,
            height: enemy.size * 2.4,
          ),
          auraPaint,
        );
        canvas.restore();
      }

      // Chromatic Glitch shadows
      paint.color = GameColors.playerGlitch.withOpacity(0.4);
      _drawEnemyShape(
        canvas,
        enemy,
        enemy.pos.x + glitchOffset,
        enemy.pos.y,
        paint,
      );

      paint.color = const Color(0xFFFF00FF).withOpacity(0.4); // Magenta offset
      _drawEnemyShape(
        canvas,
        enemy,
        enemy.pos.x - glitchOffset,
        enemy.pos.y,
        paint,
      );

      paint.color = enemy.color;
      _drawEnemyShape(canvas, enemy, enemy.pos.x, enemy.pos.y, paint);

      // Elite Indicator
      if (enemy.isElite) {
        _drawText(
          canvas,
          'ELITE',
          Offset(enemy.pos.x - 15, enemy.pos.y - enemy.size - 15),
          8,
          color: GameColors.elite,
        );
      }

      // HP Bar for boss
      if (enemy.type == EnemyType.boss || enemy.type == EnemyType.dataWorm) {
        final hpPct = (enemy.hp / enemy.maxHp).clamp(0.0, 1.0);
        final barWidth = enemy.size * 2;
        canvas.drawRect(
          Rect.fromLTWH(
            enemy.pos.x - enemy.size,
            enemy.pos.y + enemy.size + 10,
            barWidth,
            6,
          ),
          Paint()..color = Colors.black54,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            enemy.pos.x - enemy.size,
            enemy.pos.y + enemy.size + 10,
            barWidth * hpPct,
            6,
          ),
          Paint()..color = Colors.red,
        );
      }
    }
  }

  void _drawEnemyShape(
    Canvas canvas,
    Enemy enemy,
    double x,
    double y,
    Paint paint,
  ) {
    final size = enemy.size;
    switch (enemy.type) {
      case EnemyType.dataWorm:
        // Calculate offset applied to this draw call (glitch effect)
        final dx = x - enemy.pos.x;
        final dy = y - enemy.pos.y;

        // Draw Head (Diamond/Skull)
        final headPath = Path();
        headPath.moveTo(x, y - size); // Top
        headPath.lineTo(x + size, y); // Right
        headPath.lineTo(x, y + size); // Bottom
        headPath.lineTo(x - size, y); // Left
        headPath.close();
        canvas.drawPath(headPath, paint);

        // Draw Segments
        for (int i = 0; i < enemy.segments.length; i++) {
          final seg = enemy.segments[i];
          final sx = seg.x + dx;
          final sy = seg.y + dy;
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(sx, sy),
              width: size * 0.6,
              height: size * 0.6,
            ),
            paint,
          );
        }
        break;
      case EnemyType.boss:
        if (enemy.isEnraged) {
          // Furious glitching
          if ((DateTime.now().millisecondsSinceEpoch ~/ 50) % 2 == 0) {
            paint.color = Colors.white;
            paint.style = PaintingStyle.stroke;
            paint.strokeWidth = 3;
          } else {
            paint.color = const Color(0xFF8B0000); // Dark Red
            paint.style = PaintingStyle.fill;
          }
        }
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: size * 2,
            height: size * 2,
          ),
          paint,
        );
        // Inner core
        if (enemy.isEnraged) {
          canvas.drawCircle(
            Offset(x, y),
            size * 0.5,
            Paint()..color = Colors.yellow,
          );
        }
        break;
      case EnemyType.mirrorRonin:
        // Shadow Player
        final pathMR = Path();
        // Similar to player triangle
        pathMR.moveTo(x + size * 0.8, y); // Nose
        pathMR.lineTo(x - size * 0.5, y + size * 0.6);
        pathMR.lineTo(x - size * 0.5, y - size * 0.6);
        pathMR.close();

        // Rotate to face movement
        canvas.save();
        canvas.translate(x, y);
        if (enemy.aimDir != null) {
          double angle = atan2(enemy.aimDir!.y, enemy.aimDir!.x);
          canvas.rotate(angle);
        }
        canvas.translate(-x, -y);

        // Draw body
        canvas.drawPath(pathMR, paint);

        // Draw Eye
        canvas.drawCircle(
          Offset(x, y),
          size * 0.2,
          Paint()..color = Colors.redAccent,
        );

        // Draw Blade
        final bladePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x, y), Offset(x + size * 1.2, y), bladePaint);

        canvas.restore();

        // Charge indicator
        if (enemy.state == 'charge' && enemy.aimDir != null) {
          final aimP = Paint()
            ..color = Colors.red.withOpacity(0.5)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
          canvas.drawLine(
            Offset(x, y),
            Offset(x + enemy.aimDir!.x * 800, y + enemy.aimDir!.y * 800),
            aimP,
          );
        }
        break;
      case EnemyType.sniper:
        final p = Paint()
          ..color = paint.color
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x - size, y), Offset(x + size, y), p);
        canvas.drawLine(Offset(x, y - size), Offset(x, y + size), p);
        if (enemy.state == 'aim' && enemy.aimDir != null) {
          final aimPaint = Paint()
            ..color = Colors.red.withOpacity(0.5)
            ..strokeWidth = 1;
          canvas.drawLine(
            Offset(x, y),
            Offset(x + enemy.aimDir!.x * 1000, y + enemy.aimDir!.y * 1000),
            aimPaint,
          );
        }
        break;
      case EnemyType.mine:
        final path = Path();
        final s = size;
        path.moveTo(x + s * 0.5, y - s);
        path.lineTo(x + s, y - s * 0.5);
        path.lineTo(x + s, y + s * 0.5);
        path.lineTo(x + s * 0.5, y + s);
        path.lineTo(x - s * 0.5, y + s);
        path.lineTo(x - s, y + s * 0.5);
        path.lineTo(x - s, y - s * 0.5);
        path.lineTo(x - s * 0.5, y - s);
        path.close();
        if ((DateTime.now().millisecondsSinceEpoch ~/ 200) % 2 == 0) {
          paint.color = Colors.red;
        }
        canvas.drawPath(path, paint);
        break;
      case EnemyType.teleporter:
        if (enemy.state == 'vanish') {
          paint.color = paint.color.withOpacity(0.2);
          paint.style = PaintingStyle.stroke;
        } else if (enemy.state == 'reappear') {
          // Glitch effect handled by main loop, but here we can add extra
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 3;
        }
        final pathT = Path();
        pathT.moveTo(x, y - size);
        pathT.lineTo(x + size, y);
        pathT.lineTo(x, y + size);
        pathT.lineTo(x - size, y);
        pathT.close();
        canvas.drawPath(pathT, paint);
        // Inner diamond
        if (enemy.state != 'vanish') {
          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: size, height: size),
            paint..style = PaintingStyle.fill,
          );
        }
        break;
      case EnemyType.orbiter:
        final pathO = Path();
        // Triangle
        pathO.moveTo(x, y - size);
        pathO.lineTo(x + size, y + size);
        pathO.lineTo(x - size, y + size);
        pathO.close();

        // Rotate based on time
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(DateTime.now().millisecondsSinceEpoch / 300);
        canvas.translate(-x, -y);
        canvas.drawPath(
          pathO,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        // Core
        canvas.drawCircle(
          Offset(x, y),
          size * 0.4,
          paint..style = PaintingStyle.fill,
        );
        canvas.restore();
        break;
      default:
        final path = Path();
        path.moveTo(x, y - size);
        path.lineTo(x + size, y + size);
        path.lineTo(x - size, y + size);
        path.close();
        canvas.drawPath(path, paint);
    }
  }

  void _drawProjectiles(Canvas canvas) {
    for (var p in engine.projectiles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      // Tail
      if (p.tail.isNotEmpty) {
        final tailPaint = Paint()
          ..color = p.color.withOpacity(0.5)
          ..strokeWidth = p.isSniper ? 2 : 1
          ..style = PaintingStyle.stroke;
        final path = Path();
        path.moveTo(p.tail.first.x, p.tail.first.y);
        for (var pt in p.tail) {
          path.lineTo(pt.x, pt.y);
        }
        canvas.drawPath(path, tailPaint);
      }

      if (p.isPlayer) {
        // Draw player projectile shape (arc)
        canvas.save();
        canvas.translate(p.pos.x, p.pos.y);
        canvas.rotate(atan2(p.vel.y, p.vel.x));
        final path = Path();
        path.addArc(
          Rect.fromCircle(center: Offset.zero, radius: p.size),
          -pi / 2,
          pi,
        );
        path.quadraticBezierTo(-p.size / 2, 0, 0, -p.size);
        canvas.drawPath(path, paint);
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(p.pos.x, p.pos.y), p.size, paint);
      }
    }
  }

  void _drawExpOrbs(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.expOrb
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final glowPaint = Paint()
      ..color = GameColors.expOrb.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (var orb in engine.expOrbs) {
      final pulse = sin(time * 10) * 1.5;
      final floatY = sin(time * 2 + orb.pos.x) * 5;

      final drawPos = Offset(orb.pos.x, orb.pos.y + floatY);

      // Outer glow
      canvas.drawCircle(drawPos, orb.radius + 4 + pulse, glowPaint);
      // Main orb
      canvas.drawCircle(drawPos, orb.radius + pulse, paint);
      // Center highlight
      canvas.drawCircle(
        drawPos,
        orb.radius * 0.5,
        Paint()..color = Colors.white.withOpacity(0.8),
      );
    }
  }

  void _drawParticles(Canvas canvas) {
    for (var p in engine.particles) {
      final paint = Paint()
        ..color = p.color.withOpacity((p.life / p.maxLife).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(p.pos.x, p.pos.y),
          width: p.size,
          height: p.size,
        ),
        paint,
      );
    }
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (var ft in engine.floatingTexts) {
      final opacity = (ft.life / ft.maxLife).clamp(0.0, 1.0);
      _drawText(
        canvas,
        ft.text,
        Offset(ft.pos.x, ft.pos.y),
        10,
        color: ft.color.withOpacity(opacity),
        center: true,
      );
    }
  }

  void _drawHUD(Canvas canvas, Size size) {
    // Top Bar Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 100),
      Paint()..color = Colors.black.withOpacity(0.5),
    );
    canvas.drawLine(
      const Offset(0, 100),
      Offset(size.width, 100),
      Paint()
        ..color = GameColors.accent.withOpacity(0.3)
        ..strokeWidth = 1,
    );

    // Branding
    _drawText(
      canvas,
      'GLITCH_KATANA // OMEGA_v6.0',
      const Offset(20, 20),
      12,
      color: GameColors.accent.withOpacity(0.7),
    );

    // Score
    _drawText(
      canvas,
      'SCORE: ${engine.score.toString().padLeft(6, '0')}',
      const Offset(20, 45),
      22,
    );

    // Wave
    _drawText(
      canvas,
      'WAVE_ID: [${engine.wave.toString().padLeft(2, '0')}]',
      const Offset(20, 75),
      14,
      color: Colors.white70,
    );

    // Combo
    if (engine.combo > 1) {
      final comboColor = engine.comboColor;
      _drawText(
        canvas,
        'COMBO: x${engine.combo}',
        const Offset(220, 45),
        24,
        color: comboColor,
      );
      _drawText(
        canvas,
        'RANK: ${engine.comboRank}',
        const Offset(220, 75),
        16,
        color: comboColor.withOpacity(0.8),
      );
    }

    // Wave Interstitial Message
    if (engine.isWaveInterstitial) {
      final msg = engine.wave == 1
          ? '>> INITIALIZING_SYSTEM_CORE...'
          : '>> WAVE_${engine.wave - 1}_CLEARED';
      final center = size.width / 2;
      _drawText(
        canvas,
        msg,
        Offset(center - 150, size.height / 3),
        20,
        color: GameColors.accent,
      );
      _drawText(
        canvas,
        '>> DEPLOYING_NEXT_SEQUENCE_IN: ${engine.waveTimer.toStringAsFixed(1)}s',
        Offset(center - 150, size.height / 3 + 30),
        12,
        color: Colors.white54,
      );
    }

    // Level & XP (Right Side)
    final xpPct = (engine.player.xp / engine.player.nextLevelXp).clamp(
      0.0,
      1.0,
    );
    final rightX = size.width - 160;
    _drawText(
      canvas,
      'NEURAL_LEVEL: ${engine.player.level}',
      Offset(rightX, 45),
      14,
    );

    // XP Bar
    final barRect = Rect.fromLTWH(rightX, 65, 140, 8);
    canvas.drawRect(barRect, Paint()..color = Colors.white10);
    canvas.drawRect(
      Rect.fromLTWH(rightX, 65, 140 * xpPct, 8),
      Paint()..color = GameColors.expOrb,
    );
    _drawText(
      canvas,
      '${(xpPct * 100).toInt()}%',
      Offset(rightX + 145, 63),
      10,
      color: Colors.white38,
    );

    // Integrity (Health) - Bottom Left
    _drawText(
      canvas,
      'CHASSIS_INTEGRITY:',
      Offset(20, size.height - 65),
      12,
      color: Colors.white54,
    );
    for (int i = 0; i < engine.player.maxIntegrity; i++) {
      final isFilled = i < engine.player.integrity;
      final color = isFilled ? Colors.red : Colors.white10;
      final rect = Rect.fromLTWH(20.0 + (i * 35), size.height - 45, 30, 15);

      if (isFilled) {
        // Glowing health segment
        canvas.drawRect(
          rect,
          Paint()
            ..color = color.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      canvas.drawRect(rect, Paint()..color = color);
      // Border
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Time Scale Indicator - Removed text to avoid distraction (Visuals handle this)
    /*
    if (engine.timeScale < 1.0) {
      final opacity =
          (sin(DateTime.now().millisecondsSinceEpoch / 100).abs() * 0.5) + 0.2;
      _drawText(
        canvas,
        '[ BULLET_TIME_ACTIVE ]',
        Offset(size.width / 2 - 100, size.height - 100),
        16,
        color: GameColors.accent.withOpacity(opacity),
      );
    }
    */

    // Shield status
    if (engine.player.shieldUnlocked) {
      final shieldColor = engine.player.shieldActive
          ? Colors.cyan
          : Colors.white24;
      final shieldText = engine.player.shieldActive
          ? 'SHIELD: READY'
          : 'SHIELD: RECHARGING (${engine.player.shieldCooldown.toInt()}s)';
      _drawText(
        canvas,
        shieldText,
        Offset(20, size.height - 85),
        10,
        color: shieldColor,
      );
    }

    // Stance Indicator
    String stanceName = '';
    Color stanceColor = Colors.white;
    switch (engine.player.stance) {
      case GlitchStance.katana:
        stanceName = 'STANCE: KATANA';
        stanceColor = GameColors.accent;
        break;
      case GlitchStance.axe:
        stanceName = 'STANCE: H.AXE';
        stanceColor = Colors.orange;
        break;
      case GlitchStance.dual:
        stanceName = 'STANCE: DUAL';
        stanceColor = Colors.purpleAccent;
        break;
    }
    _drawText(
      canvas,
      stanceName,
      Offset(20, size.height - 105),
      14,
      color: stanceColor,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double fontSize, {
    Color color = Colors.white,
    bool center = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final drawOffset = center
        ? offset - Offset(textPainter.width / 2, textPainter.height / 2)
        : offset;
    textPainter.paint(canvas, drawOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
