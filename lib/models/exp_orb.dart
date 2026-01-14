import '../core/vector2.dart';

class ExpOrb {
  Vec2 pos;
  int value;
  double radius = 4.0;
  bool active = true;

  ExpOrb({
    required this.pos,
    required this.value,
  });

  void update(double dt, Vec2 playerPos, bool magnetEnabled) {
    final d = Vec2.distance(pos, playerPos);
    final magnetDist = magnetEnabled ? 400.0 : 250.0;
    
    if (d < magnetDist) {
      final speed = 800 * (1 - d / magnetDist) + 100;
      final dir = (playerPos - pos).normalized;
      pos += dir * (speed * dt);
    }
  }
}
