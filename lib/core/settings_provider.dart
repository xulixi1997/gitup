import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String keyHaptic = 'haptic_enabled';
  static const String keyGlitch = 'glitch_enabled';
  static const String keyHighScore = 'high_score';
  static const String keyDataFragments = 'data_fragments';
  static const String keyMaxIntegrityLevel = 'max_integrity_level';
  static const String keyAttackDamageLevel = 'attack_damage_level';
  static const String keyDataMagnetUnlocked = 'data_magnet_unlocked';
  static const String keyFragmentInventory = 'fragment_inventory_v1';
  static const String keyActiveMods = 'active_mods_v1';
  static const String keyCustomRules = 'custom_rules';
  static const String keyReduceFlashing = 'reduce_flashing';
  static const String keyTutorialShown = 'tutorial_shown';

  bool _hapticEnabled = true;
  bool _glitchEnabled = true;
  bool _reduceFlashing = false;
  bool _tutorialShown = false;
  int _highScore = 0;
  int _dataFragments = 0; // Currency (Credits)
  int _maxIntegrityLevel = 0;
  int _attackDamageLevel = 0;
  bool _dataMagnetUnlocked = false;
  
  // Fragment System
  Map<String, int> _fragmentInventory = {}; // fragmentId -> count
  List<String> _activeModIds = [];
  
  // Custom Game Rules (Terminal)
  Map<String, double> _customRules = {};
  
  bool get hapticEnabled => _hapticEnabled;
  bool get glitchEnabled => _glitchEnabled;
  bool get reduceFlashing => _reduceFlashing;
  bool get tutorialShown => _tutorialShown;
  int get highScore => _highScore;
  int get dataFragments => _dataFragments;
  int get maxIntegrityLevel => _maxIntegrityLevel;
  int get attackDamageLevel => _attackDamageLevel;
  bool get dataMagnetUnlocked => _dataMagnetUnlocked;
  
  Map<String, int> get fragmentInventory => _fragmentInventory;
  List<String> get activeModIds => _activeModIds;
  Map<String, double> get customRules => _customRules;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticEnabled = prefs.getBool(keyHaptic) ?? true;
    _glitchEnabled = prefs.getBool(keyGlitch) ?? true;
    _reduceFlashing = prefs.getBool(keyReduceFlashing) ?? false;
    _tutorialShown = prefs.getBool(keyTutorialShown) ?? false;
    _highScore = prefs.getInt(keyHighScore) ?? 0;
    _dataFragments = prefs.getInt(keyDataFragments) ?? 0;
    _maxIntegrityLevel = prefs.getInt(keyMaxIntegrityLevel) ?? 0;
    _attackDamageLevel = prefs.getInt(keyAttackDamageLevel) ?? 0;
    _dataMagnetUnlocked = prefs.getBool(keyDataMagnetUnlocked) ?? false;
    
    // Load Fragments
    final String? fragmentsJson = prefs.getString(keyFragmentInventory);
    if (fragmentsJson != null) {
      try {
        _fragmentInventory = Map<String, int>.from(jsonDecode(fragmentsJson));
      } catch (e) {
        debugPrint('Error loading fragments: $e');
      }
    }
    
    // Load Mods
    _activeModIds = prefs.getStringList(keyActiveMods) ?? [];

    // Load Custom Rules
    final String? rulesJson = prefs.getString(keyCustomRules);
    if (rulesJson != null) {
      try {
        _customRules = Map<String, double>.from(jsonDecode(rulesJson));
      } catch (e) {
        debugPrint('Error loading custom rules: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> setTutorialShown(bool value) async {
    _tutorialShown = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTutorialShown, value);
    notifyListeners();
  }
  
  Future<void> setCustomRule(String key, double value) async {
    _customRules[key] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCustomRules, jsonEncode(_customRules));
    notifyListeners();
  }
  
  Future<void> clearCustomRules() async {
    _customRules.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCustomRules);
    notifyListeners();
  }

  Future<void> updateFragmentInventory(String fragmentId, int change) async {
    final current = _fragmentInventory[fragmentId] ?? 0;
    final newValue = current + change;
    if (newValue <= 0) {
      _fragmentInventory.remove(fragmentId);
    } else {
      _fragmentInventory[fragmentId] = newValue;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFragmentInventory, jsonEncode(_fragmentInventory));
    notifyListeners();
  }
  
  Future<void> unlockMod(String modId) async {
    if (!_activeModIds.contains(modId)) {
      _activeModIds.add(modId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(keyActiveMods, _activeModIds);
      notifyListeners();
    }
  }

  Future<void> consumeFragmentsForMod(Map<String, int> requirements) async {
    for (var entry in requirements.entries) {
      final current = _fragmentInventory[entry.key] ?? 0;
      _fragmentInventory[entry.key] = current - entry.value;
      if ((_fragmentInventory[entry.key] ?? 0) <= 0) {
        _fragmentInventory.remove(entry.key);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFragmentInventory, jsonEncode(_fragmentInventory));
    // notifyListeners called by caller or implicit? Better explicit here if standalone.
    // But since this is a batch op, we notify once.
    notifyListeners();
  }

  Future<void> setMaxIntegrityLevel(int level) async {
    _maxIntegrityLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyMaxIntegrityLevel, level);
    notifyListeners();
  }

  Future<void> setAttackDamageLevel(int level) async {
    _attackDamageLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyAttackDamageLevel, level);
    notifyListeners();
  }

  Future<void> setDataMagnetUnlocked(bool value) async {
    _dataMagnetUnlocked = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDataMagnetUnlocked, value);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyHaptic, value);
    notifyListeners();
  }

  Future<void> setGlitchEnabled(bool value) async {
    _glitchEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyGlitch, value);
    notifyListeners();
  }

  Future<void> setReduceFlashing(bool value) async {
    _reduceFlashing = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyReduceFlashing, value);
    notifyListeners();
  }

  Future<void> updateHighScore(int score) async {
    if (score > _highScore) {
      _highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyHighScore, _highScore);
      notifyListeners();
    }
  }

  Future<void> addDataFragments(int amount) async {
    _dataFragments += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyDataFragments, _dataFragments);
    notifyListeners();
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _hapticEnabled = true;
    _glitchEnabled = true;
    _highScore = 0;
    _dataFragments = 0;
    _maxIntegrityLevel = 0;
    _attackDamageLevel = 0;
    _dataMagnetUnlocked = false;
    notifyListeners();
  }
}
