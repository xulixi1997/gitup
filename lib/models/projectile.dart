import '../core/vector2.dart';
import 'package:flutter/material.dart';

class Projectile {
  Vec2 pos;
  Vec2 vel;
  double size;
  bool active = true;
  double life;
  bool isPlayer;
  bool isSniper;
  Color color;
  List<Vec2> tail = [];

  Projectile({
    required this.pos,
    required this.vel,
    required this.size,
    required this.life,
    this.isPlayer = false,
    this.isSniper = false,
    required this.color,
  });

  void update(double dt) {
    tail.add(pos);
    if (tail.length > 8) tail.removeAt(0);
    pos += vel * dt;
    life -= dt;
    if (life <= 0) active = false;
  }
}
