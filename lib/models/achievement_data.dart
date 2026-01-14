import 'package:flutter/material.dart';

class AchievementData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(dynamic stats) condition;
  final Offset offset; // For the topology map
  final List<String> prerequisites; // IDs of required previous nodes

  const AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.condition,
    required this.offset,
    this.prerequisites = const [],
  });
}
