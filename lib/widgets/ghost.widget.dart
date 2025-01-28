import 'package:flutter/material.dart';

class CustomGhostWidget extends StatelessWidget {
  const CustomGhostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 0.0,
      width: 0.0,
      child: null,
    );
    // return const Placeholder(
    //   strokeWidth: 0.0,
    //   fallbackHeight: 0.0,
    //   fallbackWidth: 0.0,
    //   child: null,
    // );
  }
}
