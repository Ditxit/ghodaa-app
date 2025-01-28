import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PathDrawingWidget extends StatefulWidget {
  final String pointString;

  PathDrawingWidget({required this.pointString});

  @override
  _PathDrawingWidgetState createState() => _PathDrawingWidgetState();
}

class _PathDrawingWidgetState extends State<PathDrawingWidget> {
  List<LatLng> _points = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _parsePoints();
  }

  Future<void> _parsePoints() async {
    setState(() {
      _isLoading = true;
    });

    // Run parsing and normalization in an isolate using `compute`
    final points = await compute(_parseLatLngList, widget.pointString);
    setState(() {
      _points = points;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator() // Show loading indicator
          : CustomPaint(
              size: Size(300, 300),
              painter: PathPainter(_points),
            ),
    );
  }
}

// Function to parse the string and normalize points, runs in an isolate
List<LatLng> _parseLatLngList(String pointString) {
  final parts = pointString.split(',');
  List<LatLng> points = [];
  double? minLat, maxLat, minLng, maxLng;

  // Parse lat-long pairs and find min/max for normalization
  for (int i = 0; i < parts.length; i += 2) {
    final lat = double.parse(parts[i]);
    final lon = double.parse(parts[i + 1]);
    points.add(LatLng(lat, lon));
    if (minLat == null || lat < minLat) minLat = lat;
    if (maxLat == null || lat > maxLat) maxLat = lat;
    if (minLng == null || lon < minLng) minLng = lon;
    if (maxLng == null || lon > maxLng) maxLng = lon;
  }

  // Normalize points based on min/max latitude and longitude
  return points.map((point) {
    final dx = ((point.longitude - minLng!) / (maxLng! - minLng)) * 300;
    final dy = 300 - ((point.latitude - minLat!) / (maxLat! - minLat)) * 300;
    return LatLng(dx, dy);
  }).toList();
}

class PathPainter extends CustomPainter {
  final List<LatLng> points;

  PathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.latitude, points.first.longitude);
      for (var point in points.skip(1)) {
        path.lineTo(point.latitude, point.longitude);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => oldDelegate.points != points;
}
