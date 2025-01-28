import 'dart:math';
import 'package:flutter/material.dart';

class BearingAngleWidget extends StatelessWidget {
  final double currentLat;
  final double currentLon;
  final double targetLat;
  final double targetLon;

  const BearingAngleWidget({
    super.key,
    required this.currentLat,
    required this.currentLon,
    required this.targetLat,
    required this.targetLon,
  });

  double calculateBearing() {
    // Convert degrees to radians
    double phi1 = currentLat * (pi / 180);
    double phi2 = targetLat * (pi / 180);
    double deltaLambda = (targetLon - currentLon) * (pi / 180);

    double x = sin(deltaLambda) * cos(phi2);
    double y = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);

    // Calculate the bearing
    double initialBearing = atan2(x, y);

    // Convert radians to degrees and normalize to 0-360 degrees
    double bearing = (initialBearing * (180 / pi) + 360) % 360;
    return bearing;
  }

  @override
  Widget build(BuildContext context) {
    double bearing = calculateBearing();

    return SizedBox(
      height: 300.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arrow pointing in the direction of the bearing
          Transform.rotate(
            angle: (bearing - 90) * (pi / 180), // Adjust to point upwards
            child: Icon(
              Icons.arrow_upward,
              size: 100,
              color: Colors.blue,
            ),
          ),
          // Display the bearing value
          Positioned(
            bottom: 20,
            child: Text(
              'Bearing: ${bearing.toStringAsFixed(2)}°',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: BearingAngleArrowWidget(
//       currentLat: 37.7749, // Example current latitude
//       currentLon: -122.4194, // Example current longitude
//       targetLat: 34.0522, // Example target latitude
//       targetLon: -118.2437, // Example target longitude
//     ),
//   ));
// }
