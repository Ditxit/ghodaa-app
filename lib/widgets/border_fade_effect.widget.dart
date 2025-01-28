import 'package:flutter/material.dart';

class BorderFadeEffect extends StatelessWidget {
  final Widget child; // The child widget, e.g., GoogleMap

  const BorderFadeEffect({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Actual child widget, e.g., GoogleMap
        child,

        // ShaderMask to create the fade effect around the edges
        IgnorePointer(
          ignoring: true,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 0, 0, 0), // Fully opaque at the top
                  Color.fromARGB(0, 0, 0, 0), // Transparent at the center
                  Color.fromARGB(0, 0, 0, 0), // Transparent at the center
                  Color.fromARGB(255, 0, 0, 0), // Fully opaque at the bottom
                ],
                stops: [
                  0.0,
                  0.2,
                  0.8,
                  1.0,
                ],
              ).createShader(rect);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black, // Ensure background is transparent
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BorderFadeEffectRedial extends StatelessWidget {
  final Widget child; // The child widget, e.g., GoogleMap

  const BorderFadeEffectRedial({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Actual child widget, e.g., GoogleMap
        child,

        // ShaderMask to create the fade effect around the edges
        IgnorePointer(
          ignoring: true,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (Rect rect) {
              return RadialGradient(
                center: Alignment.center,
                radius: 0.9, // Adjusted radius to fit the container
                colors: [
                  Color.fromARGB(0, 0, 0, 0),
                  Color.fromARGB(0, 0, 0, 0),
                  Color.fromARGB(255, 0, 0, 0), // Fully opaque at the edges
                  Color.fromARGB(255, 0, 0, 0), // Fully opaque at the edges
                ],
                stops: [
                  0.0, // Start with transparent at the center
                  0.2, // Transition to transparent
                  0.75, // Transition to transparent
                  1.0, // End with fully opaque
                ],
              ).createShader(rect);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black, // Ensure background is transparent
              ),
            ),
          ),
        ),
      ],
    );
  }
}
