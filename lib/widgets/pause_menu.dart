import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart' hide GameState;
import '../game/game_engine.dart';
import 'menu_button.dart';

class PauseMenu extends StatefulWidget {
  const PauseMenu({super.key});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context, listen: false);

    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SlideTransition(
                position: _slideIn,
                child: _ShimmerWidget(
                  child: Text(
                    '// SYSTEM_PAUSED',
                    style: GameStyles.glitchTitle.copyWith(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'WAITING_FOR_INPUT...',
                style: GameStyles.labelText.copyWith(
                  color: Colors.white54,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),
              MenuButton(
                label: 'RESUME_PROTOCOL',
                onPressed: () => engine.togglePause(),
                isPrimary: true,
              ),
              const SizedBox(height: 20),
              MenuButton(
                label: 'ABORT_MISSION',
                onPressed: () {
                  engine.togglePause(); // Unpause logic state
                  engine.state = GameState.menu; // Force state to menu
                  engine.notifyListeners(); // Ensure UI updates
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                isWarning: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerWidget extends StatefulWidget {
  final Widget child;

  const _ShimmerWidget({required this.child});

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              colors: [
                Colors.white.withOpacity(0.1),
                GameColors.accent,
                Colors.white.withOpacity(0.1),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
