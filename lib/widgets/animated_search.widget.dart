import 'package:flutter/material.dart';

class AnimatedSearchWidget extends StatefulWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const AnimatedSearchWidget({
    super.key,
    this.color = Colors.yellow, // Default color
    this.size = 300.0, // Default size for radar
    this.strokeWidth = 4.0, // Default stroke width
  });

  @override
  _AnimatedSearchWidgetState createState() => _AnimatedSearchWidgetState();
}

class _AnimatedSearchWidgetState extends State<AnimatedSearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Faster ring generation
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Repeat the animation indefinitely
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring animation
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size), // Use widget's size
                painter: RadarPainter(
                  widget.color,
                  _animation.value,
                  widget.strokeWidth, // Pass the strokeWidth
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double strokeWidth;

  RadarPainter(this.color, this.progress, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth; // Use the custom stroke width

    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    double maxRadius = radius;
    const int numRings = 4;

    // Draw expanding and fading rings
    for (int i = 0; i < numRings; i++) {
      double currentRadius = maxRadius * ((progress + i / numRings) % 1);
      double opacity = (1 - currentRadius / maxRadius).clamp(0.0, 1.0);
      paint.color = color.withOpacity(opacity * 0.6);

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
