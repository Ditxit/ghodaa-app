import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool expanded;

  const FrostedButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.expanded = false, // Control button width
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0), // Round the corners
      child: Material(
        color: Colors.transparent, // Set color to transparent to see the blur
        child: InkWell(
          onTap: onPressed,
          borderRadius:
              BorderRadius.circular(12.0), // Match border radius for ripple
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Blur
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
                child: Container(
                  width: expanded ? double.infinity : 160,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(60), // semi-transparent white
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.white.withAlpha(30),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Icon and Text
              _buildButtonContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (icon != null) _buildIcon(),
        if (icon != null) const SizedBox(width: 8), // Spacing
        _buildText(),
      ],
    );
  }

  Widget _buildIcon() {
    return Icon(
      icon,
      color: Colors.white,
      size: 24,
      shadows: _getIconShadows(),
    );
  }

  List<Shadow> _getIconShadows() {
    return [
      Shadow(
        color: Colors.black.withAlpha(60),
        offset: const Offset(1, 1),
        blurRadius: 3,
      ),
    ];
  }

  Widget _buildText() {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: _getTextShadows(),
      ),
    );
  }

  List<Shadow> _getTextShadows() {
    return [
      Shadow(
        color: Colors.black.withAlpha(60),
        offset: const Offset(1, 1),
        blurRadius: 3,
      ),
    ];
  }
}
