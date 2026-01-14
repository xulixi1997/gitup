import 'package:flutter/material.dart';
import '../core/vector2.dart';

class Particle {
  Vec2 pos;
  Vec2 vel;
  double life;
  double maxLife;
  Color color;
  double size;

  Particle({
    required this.pos,
    required this.vel,
    required this.life,
    required this.color,
    this.size = 2.0,
  }) : maxLife = life;

  void update(double dt) {
    pos += vel * dt;
    life -= dt;
  }
}
