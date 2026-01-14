
enum CorruptionType {
  overclock, // +Atk Speed, +Damage taken
  memoryLeak, // +Move Speed, -HP/sec, +Heal on kill
  glitchVision, // +Score/Gold, +Visual Noise
  glassCannon, // +Damage, -MaxHP
  heavyWeight, // +Defense, -Move Speed
}

class Corruption {
  final String id;
  final String name;
  final String description;
  final String risk;
  final String reward;
  final CorruptionType type;

  const Corruption({
    required this.id,
    required this.name,
    required this.description,
    required this.risk,
    required this.reward,
    required this.type,
  });

  static List<Corruption> get all => [
    const Corruption(
      id: 'overclock',
      name: 'OVERCLOCK_PROTOCOL',
      description: 'Push hardware limits.',
      risk: 'Incoming Damage +50%',
      reward: 'Attack Speed +30%',
      type: CorruptionType.overclock,
    ),
    const Corruption(
      id: 'memory_leak',
      name: 'MEMORY_LEAK',
      description: 'Sacrifice stability for speed.',
      risk: 'Lose 1 HP/sec',
      reward: 'Move Speed +30% & Heal on Kill',
      type: CorruptionType.memoryLeak,
    ),
    const Corruption(
      id: 'glitch_vision',
      name: 'GLITCH_VISION',
      description: 'Corrupt visual sensors.',
      risk: 'Severe Visual Interference',
      reward: 'Score Multiplier +50%',
      type: CorruptionType.glitchVision,
    ),
    const Corruption(
      id: 'glass_cannon',
      name: 'GLASS_CANNON',
      description: 'Maximize output, minimize safety.',
      risk: 'Max HP -30%',
      reward: 'Damage +40%',
      type: CorruptionType.glassCannon,
    ),
  ];
}
