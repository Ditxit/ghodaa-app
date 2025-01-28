import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ghodaa/screens/landing.screen.dart';
import 'package:confetti/confetti.dart';

class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({super.key});

  @override
  _CelebrationScreenState createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    // Navigate to the LandingScreen after all confetti has been displayed
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          _createRoute(),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LandingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0; // Starting opacity
        const end = 1.0; // Ending opacity
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: child,
        );
      },
      transitionDuration:
          const Duration(milliseconds: 500), // Duration of the transition
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Confetti coming from different directions
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2, // From top left
              emissionFrequency: 0.05,
              numberOfParticles: 15, // Fewer particles
              gravity: 0.4,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2, // From top center
              emissionFrequency: 0.05,
              numberOfParticles: 15, // Fewer particles
              gravity: 0.4,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2, // From top right
              emissionFrequency: 0.05,
              numberOfParticles: 15, // Fewer particles
              gravity: 0.4,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedTickPatch(), // Animated green tick
                const SizedBox(height: 20),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You have successfully completed your ride.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated tick patch widget
class AnimatedTickPatch extends StatefulWidget {
  @override
  _AnimatedTickPatchState createState() => _AnimatedTickPatchState();
}

class _AnimatedTickPatchState extends State<AnimatedTickPatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
    );
  }
}
