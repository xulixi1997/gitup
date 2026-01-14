import 'package:flutter/foundation.dart';

class ShopItem {
  final String id;
  final String title;
  final String description;
  final int baseCost;
  final int Function(int currentLevel) costCurve;
  final int maxLevel; // 0 for infinite
  final bool isOneTime; // For unlocks like Data Magnet
  final VoidCallback? onPurchase; // Logic to apply

  const ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.baseCost,
    this.costCurve = _defaultCostCurve,
    this.maxLevel = 0,
    this.isOneTime = false,
    this.onPurchase,
  });

  static int _defaultCostCurve(int level) => (level + 1) * 10;
}
