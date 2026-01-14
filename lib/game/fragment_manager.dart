import 'dart:math';
import '../models/fragment.dart';
import '../models/enemy.dart';
import '../core/settings_provider.dart';

class FragmentManager {
  final SettingsProvider settings;
  final Random _random = Random();

  FragmentManager(this.settings);

  // --- Crafting Logic ---

  bool canCraft(String recipeId) {
    final recipe = FragmentDatabase.recipes.firstWhere((r) => r.id == recipeId, orElse: () => throw Exception('Recipe not found'));
    
    // Check if already crafted (assuming mods are unique/one-time for now)
    if (settings.activeModIds.contains(recipe.result.id)) {
      return false; 
    }

    for (var entry in recipe.requiredFragments.entries) {
      final owned = settings.fragmentInventory[entry.key] ?? 0;
      if (owned < entry.value) return false;
    }
    return true;
  }

  Future<bool> craft(String recipeId) async {
    if (!canCraft(recipeId)) return false;

    final recipe = FragmentDatabase.recipes.firstWhere((r) => r.id == recipeId);
    
    // 1. Consume Fragments
    await settings.consumeFragmentsForMod(recipe.requiredFragments);
    
    // 2. Unlock Mod
    await settings.unlockMod(recipe.result.id);
    return true;
  }

  // --- Gameplay Logic ---

  Map<String, double> getAggregatedStats() {
    final stats = <String, double>{};
    
    for (var modId in settings.activeModIds) {
      // Find the mod definition. Since we don't store the full mod object, we look it up.
      // We assume mod IDs are unique across all recipes.
      try {
        final recipe = FragmentDatabase.recipes.firstWhere((r) => r.result.id == modId);
        final mod = recipe.result;
        
        mod.stats.forEach((key, value) {
          stats[key] = (stats[key] ?? 0.0) + value;
        });
      } catch (e) {
        // Mod might have been removed from DB or invalid ID
        continue;
      }
    }
    return stats;
  }

  /// Returns a fragment ID if one drops, or null.
  String? checkDrop(EnemyType enemyType, int combo) {
    // Base drop chance
    double chance = 0.05; // 5% base
    
    // Combo multiplier
    if (combo > 10) chance += 0.05;
    if (combo > 30) chance += 0.10;
    
    // Enemy type multiplier
    if (enemyType == EnemyType.boss || enemyType == EnemyType.dataWorm || enemyType == EnemyType.mirrorRonin) {
      chance = 1.0; // Bosses always drop something
    } else if (enemyType == EnemyType.sniper || enemyType == EnemyType.orbiter) {
      chance += 0.05; // Elites have higher chance
    }

    if (_random.nextDouble() > chance) return null;

    // Determine type based on enemy
    List<Fragment> pool = FragmentDatabase.allFragments.where((f) => f.rarity == FragmentRarity.common).toList();
    
    if (enemyType == EnemyType.boss || enemyType == EnemyType.mirrorRonin) {
       pool = FragmentDatabase.allFragments.where((f) => f.rarity == FragmentRarity.rare || f.rarity == FragmentRarity.legendary).toList();
    } else if (enemyType == EnemyType.dataWorm) {
       pool = FragmentDatabase.allFragments.where((f) => f.type == FragmentType.memory).toList();
    }
    
    if (pool.isEmpty) pool = FragmentDatabase.allFragments;

    return pool[_random.nextInt(pool.length)].id;
  }
}
