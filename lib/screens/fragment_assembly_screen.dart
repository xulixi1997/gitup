import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/settings_provider.dart';
import '../game/fragment_manager.dart';
import '../models/fragment.dart';
import '../widgets/glitch_scaffold.dart';

class FragmentAssemblyScreen extends StatefulWidget {
  const FragmentAssemblyScreen({super.key});

  @override
  State<FragmentAssemblyScreen> createState() => _FragmentAssemblyScreenState();
}

class _FragmentAssemblyScreenState extends State<FragmentAssemblyScreen> {
  String? _selectedRecipeId;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final manager = FragmentManager(settings);

    return GlitchScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '// FRAGMENT_ASSEMBLY_TERMINAL',
                  style: TextStyle(
                    color: GameColors.accent,
                    fontSize: 20,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: GameColors.accent),
            const SizedBox(height: 20),

            // Main Content: Split View (Inventory vs Recipes)
            Expanded(
              child: Row(
                children: [
                  // Left: Inventory & Active Mods
                  Expanded(
                    flex: 2,
                    child: _buildInventoryPanel(settings),
                  ),
                  const SizedBox(width: 20),
                  // Right: Recipes & Crafting
                  Expanded(
                    flex: 3,
                    child: _buildRecipesPanel(settings, manager),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryPanel(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('>> FRAGMENT_STORAGE', style: GameStyles.glitchTitle.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              color: Colors.black54,
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: FragmentDatabase.allFragments.length,
              itemBuilder: (context, index) {
                final fragment = FragmentDatabase.allFragments[index];
                final count = settings.fragmentInventory[fragment.id] ?? 0;
                return _buildFragmentSlot(fragment, count);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('>> ACTIVE_MODS', style: GameStyles.glitchTitle.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              color: Colors.black54,
            ),
            child: ListView.builder(
              itemCount: settings.activeModIds.length,
              itemBuilder: (context, index) {
                final modId = settings.activeModIds[index];
                // Find mod definition
                final recipe = FragmentDatabase.recipes.firstWhere(
                    (r) => r.result.id == modId,
                    orElse: () => FragmentDatabase.recipes.first);
                return ListTile(
                  title: Text(recipe.result.name,
                      style: const TextStyle(
                          color: Colors.greenAccent, fontFamily: 'monospace')),
                  subtitle: Text(recipe.result.description,
                      style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  dense: true,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFragmentSlot(Fragment fragment, int count) {
    final color = _getRarityColor(fragment.rarity);
    return Tooltip(
      message: '${fragment.name}\n${fragment.description}',
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: count > 0 ? color : Colors.white10),
          color: count > 0 ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.memory,
                color: count > 0 ? color : Colors.white10, size: 24),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                  color: count > 0 ? Colors.white : Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesPanel(SettingsProvider settings, FragmentManager manager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('>> ASSEMBLY_PROTOCOLS', style: GameStyles.glitchTitle.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: FragmentDatabase.recipes.length,
            itemBuilder: (context, index) {
              final recipe = FragmentDatabase.recipes[index];
              final isUnlocked = settings.activeModIds.contains(recipe.result.id);
              final canCraft = manager.canCraft(recipe.id);
              final isSelected = _selectedRecipeId == recipe.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRecipeId = recipe.id;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? GameColors.accent : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isUnlocked
                        ? Colors.green.withOpacity(0.05)
                        : Colors.black54,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isUnlocked
                                ? Icons.check_circle
                                : (canCraft ? Icons.lock_open : Icons.lock),
                            color: isUnlocked
                                ? Colors.green
                                : (canCraft ? GameColors.accent : Colors.grey),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(recipe.result.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text(recipe.result.description,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isSelected && !isUnlocked) ...[
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white10),
                        const Text('REQUIRED_FRAGMENTS:',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'monospace')),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          children: recipe.requiredFragments.entries.map((e) {
                            final fragName = FragmentDatabase.allFragments
                                .firstWhere((f) => f.id == e.key)
                                .name;
                            final have = settings.fragmentInventory[e.key] ?? 0;
                            final need = e.value;
                            final hasEnough = have >= need;
                            return Chip(
                              label: Text('$fragName $have/$need',
                                  style: TextStyle(
                                      color: hasEnough
                                          ? Colors.white
                                          : Colors.redAccent,
                                      fontSize: 10)),
                              backgroundColor: hasEnough
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              side: BorderSide(
                                  color: hasEnough
                                      ? Colors.green
                                      : Colors.redAccent),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canCraft
                                ? () async {
                                    final success = await manager.craft(recipe.id);
                                    if (success && context.mounted) {
                                      setState(() {
                                        _selectedRecipeId = null;
                                      });
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canCraft
                                  ? GameColors.accent
                                  : Colors.grey.withOpacity(0.2),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('ASSEMBLE_MOD',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace')),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRarityColor(FragmentRarity rarity) {
    switch (rarity) {
      case FragmentRarity.common:
        return Colors.white;
      case FragmentRarity.uncommon:
        return Colors.greenAccent;
      case FragmentRarity.rare:
        return Colors.blueAccent;
      case FragmentRarity.legendary:
        return Colors.orangeAccent;
    }
  }
}
