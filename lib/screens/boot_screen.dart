import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/glitch_scaffold.dart';
import '../widgets/glitch_page_route.dart';
import '../core/constants.dart';
import 'main_navigation_screen.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  final List<String> _logs = [];
  final List<String> _messages = [
    "> INITIALIZING NEURAL_LINK...",
    "> LOADING CORE_KERNEL V6.0...",
    "> BYPASSING SECURITY_LAYER...",
    "> CONNECTING TO OMEGA_NETWORK...",
    "> CALIBRATING GLITCH_KATANA...",
    "> ACCESS GRANTED.",
    "> WELCOME, RONIN.",
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startBootSequence();
  }

  void _startBootSequence() {
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_currentIndex < _messages.length) {
        setState(() {
          _logs.add(_messages[_currentIndex]);
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              GlitchPageRoute(page: const MainNavigationScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlitchScaffold(
      child: Stack(
        children: [
          // Scanline effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.overlay,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '// OMEGA_OS_TERMINAL_V6.0',
                  style: TextStyle(
                    color: GameColors.accent,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                ..._logs.map((log) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        log,
                        style: const TextStyle(
                          color: GameColors.accent,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: GameColors.accent, blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                if (_currentIndex < _messages.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(GameColors.accent),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'ANALYZING...',
                          style: GameStyles.labelText.copyWith(color: GameColors.accent.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                const Text(
                  'ESTABLISHING_SECURE_CONNECTION...',
                  style: TextStyle(
                    color: Colors.white10,
                    fontSize: 8,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.05),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentIndex / _messages.length).clamp(0.0, 1.0),
                    child: Container(color: GameColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
