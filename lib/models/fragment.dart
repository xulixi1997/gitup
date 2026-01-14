
enum FragmentType {
  memory, // Blue - Storage/Capacity
  processor, // Red - Speed/Damage
  kernel, // Green - Core Logic/Defense
  glitch, // Purple - Chaos/Special
}

enum FragmentRarity {
  common,
  uncommon,
  rare,
  legendary,
}

class Fragment {
  final String id;
  final String name;
  final String description;
  final FragmentType type;
  final FragmentRarity rarity;

  const Fragment({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
  });

  String get terminalCode => '[${type.name.toUpperCase()}_${id.toUpperCase()}]';
}

class PassiveMod {
  final String id;
  final String name;
  final String description;
  final Map<String, double> stats; // e.g., {'damage': 0.1, 'speed': 0.05}

  const PassiveMod({
    required this.id,
    required this.name,
    required this.description,
    required this.stats,
  });
}

class AssemblyRecipe {
  final String id;
  final PassiveMod result;
  final Map<String, int> requiredFragments; // fragmentId -> count

  const AssemblyRecipe({
    required this.id,
    required this.result,
    required this.requiredFragments,
  });
}

// Static Data Definitions
class FragmentDatabase {
  static const List<Fragment> allFragments = [
    Fragment(
      id: 'mem_seg_01',
      name: 'Corrupted Sector',
      description: 'A damaged memory block containing movement data.',
      type: FragmentType.memory,
      rarity: FragmentRarity.common,
    ),
    Fragment(
      id: 'cpu_cycle_a',
      name: 'Overclocked Cycle',
      description: 'Residual heat from a high-speed process.',
      type: FragmentType.processor,
      rarity: FragmentRarity.common,
    ),
    Fragment(
      id: 'kernel_dump',
      name: 'Kernel Dump',
      description: 'Protected system logs.',
      type: FragmentType.kernel,
      rarity: FragmentRarity.uncommon,
    ),
    Fragment(
      id: 'void_pointer',
      name: 'Void Pointer',
      description: 'Points to nowhere. Or everywhere.',
      type: FragmentType.glitch,
      rarity: FragmentRarity.rare,
    ),
  ];

  static const List<AssemblyRecipe> recipes = [
    AssemblyRecipe(
      id: 'mod_speed_hack',
      result: PassiveMod(
        id: 'speed_hack_v1',
        name: 'SpeedHack.exe',
        description: 'Increases movement speed by 10%.',
        stats: {'moveSpeed': 0.10},
      ),
      requiredFragments: {'mem_seg_01': 3, 'cpu_cycle_a': 1},
    ),
    AssemblyRecipe(
      id: 'mod_logic_gate',
      result: PassiveMod(
        id: 'logic_gate_shield',
        name: 'LogicGate.sh',
        description: 'Reduces incoming damage by 5%.',
        stats: {'defense': 0.05},
      ),
      requiredFragments: {'kernel_dump': 2, 'mem_seg_01': 2},
    ),
    AssemblyRecipe(
      id: 'mod_chaos_engine',
      result: PassiveMod(
        id: 'chaos_engine',
        name: 'ChaosEngine.bin',
        description: 'Critical hit chance +15%.',
        stats: {'critChance': 0.15},
      ),
      requiredFragments: {'void_pointer': 1, 'cpu_cycle_a': 5},
    ),
  ];
}
