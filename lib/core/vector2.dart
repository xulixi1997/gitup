import 'dart:math';

class Vec2 {
  final double x;
  final double y;

  const Vec2(this.x, this.y);

  static const Vec2 zero = Vec2(0, 0);

  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);
  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);
  Vec2 operator *(double scalar) => Vec2(x * scalar, y * scalar);
  Vec2 operator /(double scalar) => Vec2(x / scalar, y / scalar);

  double get magnitude => sqrt(x * x + y * y);
  double get sqrMagnitude => x * x + y * y;

  Vec2 get normalized {
    final m = magnitude;
    return m == 0 ? Vec2.zero : this / m;
  }

  static double distance(Vec2 v1, Vec2 v2) => (v1 - v2).magnitude;

  static double distPointToLine(Vec2 p, Vec2 v, Vec2 w) {
    final l2 = (v - w).sqrMagnitude;
    if (l2 == 0) return distance(p, v);
    var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
    t = max(0, min(1, t));
    final projection = v + (w - v) * t;
    return distance(p, projection);
  }

  @override
  String toString() => 'Vec2($x, $y)';
}
