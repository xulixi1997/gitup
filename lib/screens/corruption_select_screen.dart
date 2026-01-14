
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/corruption.dart';
import '../core/constants.dart';

class CorruptionSelectScreen extends StatelessWidget {
  const CorruptionSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);
    final corruptions = engine.availableCorruptions;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent, width: 2),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SYSTEM CORRUPTION DETECTED',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'Courier',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'PROTOCOL INJECTION REQUIRED',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              ...corruptions.map((c) => _buildCorruptionCard(context, engine, c)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorruptionCard(BuildContext context, GameEngine engine, Corruption corruption) {
    return GestureDetector(
      onTap: () => engine.selectCorruption(corruption),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              corruption.name,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontFamily: 'Courier',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              corruption.description,
              style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Courier',
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    corruption.risk,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'Courier'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    corruption.reward,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'Courier'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
