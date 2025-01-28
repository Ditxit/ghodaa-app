import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng class

class PolygonPainter extends CustomPainter {
  final List<LatLng> points; // Polygon points

  PolygonPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.3) // Polygon fill color
      ..style = PaintingStyle.fill;

    Paint strokePaint = Paint()
      ..color = Colors.blueAccent // Polygon border color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    Path path = Path();
    if (points.isNotEmpty) {
      Offset firstPoint = _latLngToOffset(points.first, size);
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (var i = 1; i < points.length; i++) {
        Offset point = _latLngToOffset(points[i], size);
        path.lineTo(point.dx, point.dy);
      }

      path.close(); // Close the path to form the polygon
      canvas.drawPath(path, paint); // Fill the polygon
      canvas.drawPath(path, strokePaint); // Draw the polygon border
    }
  }

  Offset _latLngToOffset(LatLng latLng, Size size) {
    // Custom logic to map LatLng to screen coordinates
    double x = (latLng.longitude + 180) * (size.width / 360);
    double y = (90 - latLng.latitude) * (size.height / 180);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint when points change
  }
}

class MapPolygonPainter extends StatelessWidget {
  final List<LatLng> polygonPoints;

  const MapPolygonPainter({Key? key, required this.polygonPoints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Full width
      height: double.infinity, // Full height
      child: CustomPaint(
        painter: PolygonPainter(polygonPoints), // Pass polygon points
      ),
    );
  }
}
