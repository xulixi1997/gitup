import 'package:flutter/material.dart';
import '../core/constants.dart';

class GlitchPageRoute extends PageRouteBuilder {
  final Widget page;

  GlitchPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Intro: Slide in from bottom + Fade + Glitch Vertical Scanline
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutExpo,
            ));

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ));

            // Outro (Secondary): Zoom in slightly and fade out
            final scaleSecondary = Tween<double>(
              begin: 1.0,
              end: 1.1,
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeIn,
            ));

            final fadeSecondary = Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeIn,
            ));

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                // "Scanline" effect using ClipRect or just simple transform
                // Simulating a vertical opening effect
                double scanlineHeight = (1.0 - animation.value) * 100;
                
                return Stack(
                  children: [
                    // Previous Page (controlled by secondaryAnimation when pushing NEW page)
                    if (secondaryAnimation.value > 0)
                      Opacity(
                        opacity: fadeSecondary.value,
                        child: Transform.scale(
                          scale: scaleSecondary.value,
                          child: child,
                        ),
                      ),
                      
                    // New Page (controlled by animation)
                    if (secondaryAnimation.value == 0)
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: SlideTransition(
                          position: slideAnimation,
                          child: Stack(
                            children: [
                              child!,
                              // Scanline overlay during transition
                              if (animation.value < 1.0)
                                Positioned(
                                  top: MediaQuery.of(context).size.height * animation.value,
                                  left: 0,
                                  right: 0,
                                  height: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: GameColors.accent.withOpacity(0.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: GameColors.accent,
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              child: child,
            );
          },
        );
}
