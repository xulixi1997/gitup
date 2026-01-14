import '../core/vector2.dart';

enum GlitchStance { katana, axe, dual }

class Player {
  Vec2 pos;
  Vec2 lastPos;
  Vec2 vel;
  double size = 12.0;
  bool isDashing = false;
  double dashDuration = 0.0;
  int integrity;
  int maxIntegrity;

  // Stance System
  GlitchStance stance = GlitchStance.katana;
  double stanceCooldown = 0.0;

  int xp = 0;
  int level = 1;
  int nextLevelXp = 500;
  double damageMultiplier = 1.0;
  double corruptionAttackSpeedBonus = 0.0;

  // Fragment Stats
  double moveSpeedBonus = 0.0;
  double defenseBonus = 0.0;
  double critChance = 0.0;

  bool swordBeamUnlocked = false;
  bool wideBladeUnlocked = false;
  bool dataMagnetUnlocked = false;
  bool shieldUnlocked = false;
  bool overclockUnlocked = false;

  double shieldCooldown = 0.0;
  bool shieldActive = false;
  double overclockTimer = 0.0;

  // Just Defend
  double parryWindow = 0.0;

  List<PlayerTrail> trails = [];

  Player({
    required this.pos,
    this.vel = Vec2.zero,
    this.integrity = 4,
    this.maxIntegrity = 4,
  }) : lastPos = pos;

  void switchStance() {
    if (stanceCooldown > 0) return;

    switch (stance) {
      case GlitchStance.katana:
        stance = GlitchStance.axe;
        break;
      case GlitchStance.axe:
        stance = GlitchStance.dual;
        break;
      case GlitchStance.dual:
        stance = GlitchStance.katana;
        break;
    }
    stanceCooldown = 0.5; // Prevent spamming
    parryWindow = 0.25; // Trigger Just Defend window
  }

  // Stance-specific Getters
  double get attackSpeedMulti {
    double base = 1.0;
    switch (stance) {
      case GlitchStance.katana:
        base = 1.0;
        break;
      case GlitchStance.axe:
        base = 0.5;
        break;
      case GlitchStance.dual:
        base = 2.0;
        break;
    }
    return base + corruptionAttackSpeedBonus;
  }

  double get stanceDamageMulti {
    switch (stance) {
      case GlitchStance.katana:
        return 1.0;
      case GlitchStance.axe:
        return 3.0;
      case GlitchStance.dual:
        return 0.6;
    }
  }

  double get dashRangeMulti {
    switch (stance) {
      case GlitchStance.katana:
        return 1.0;
      case GlitchStance.axe:
        return 0.6; // Heavy dash
      case GlitchStance.dual:
        return 1.3; // Blink
    }
  }

  bool gainXp(int amount) {
    xp += amount;
    if (xp >= nextLevelXp) {
      levelUp();
      return true;
    }
    return false;
  }

  void levelUp() {
    xp -= nextLevelXp;
    level++;
    nextLevelXp = (nextLevelXp * 1.5).toInt();
    integrity = (integrity + 1).clamp(0, maxIntegrity);
    damageMultiplier += 0.1;
  }

  void update(double dt, {double speedMult = 1.0}) {
    if (stanceCooldown > 0) stanceCooldown -= dt;
    if (parryWindow > 0) parryWindow -= dt;

    lastPos = pos;
    double actualDt = overclockTimer > 0 ? dt * 1.5 : dt;
    pos += vel * actualDt * speedMult;

    if (isDashing) {
      dashDuration += dt;
      vel *= 0.90;
      if (vel.magnitude < 50) {
        isDashing = false;
        vel = Vec2.zero;
      }
    }
  }
}

class PlayerTrail {
  Vec2 pos;
  double life;
  double width;
  PlayerTrail({required this.pos, required this.life, required this.width});
}
