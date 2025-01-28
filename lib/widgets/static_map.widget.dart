import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StaticMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> locations; // List of marker attributes
  final double height;
  final double width;

  const StaticMapWidget({
    super.key,
    required this.locations,
    this.height = 300, // Default height
    this.width = double.infinity, // Default width
  });

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers(locations);
    final centerLocation = _calculateCenter(locations);
    final zoomLevel = _calculateZoomLevel(locations);

    final MapController mapController = MapController();
    // Move the map to the new center and zoom level
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(centerLocation, zoomLevel);
    });

    return SizedBox(
      height: height,
      width: width,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: centerLocation,
          initialZoom: zoomLevel,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<Map<String, dynamic>> locations) {
    return locations.map((location) {
      return Marker(
        point: LatLng(location['latitude'], location['longitude']),
        child: _buildMarker(
          location['name'],
          location['color'],
          location['icon'],
        ),
      );
    }).toList();
  }

  Widget _buildMarker(String name, Color color, IconData icon) {
    return Icon(
      icon,
      color: color,
      size: 60, // Icon size
    );
    // return Container(
    //   width: 60, // Fixed width for the marker
    //   height: 60, // Fixed height for the marker
    //   decoration: BoxDecoration(
    //     shape: BoxShape.circle,
    //     color: color,
    //     border: Border.all(color: color, width: 2),
    //     boxShadow: [
    //       BoxShadow(
    //         color: color.withOpacity(0.6),
    //         spreadRadius: 6,
    //         blurRadius: 12,
    //         offset: const Offset(0, 0),
    //       ),
    //     ],
    //   ),
    //   alignment: Alignment.center,
    //   child: Icon(
    //     icon,
    //     color: Colors.white,
    //     size: 28, // Icon size
    //   ),
    // );
  }

  LatLng _calculateCenter(List<Map<String, dynamic>> locations) {
    if (locations.isEmpty) {
      return const LatLng(0.0, 0.0); // Fallback to a default point
    }

    return LatLng(
      locations.map((loc) => loc['latitude']).reduce((a, b) => a + b) /
          locations.length,
      locations.map((loc) => loc['longitude']).reduce((a, b) => a + b) /
          locations.length,
    );
  }

  double _calculateZoomLevel(List<Map<String, dynamic>> locations) {
    if (locations.isEmpty) {
      return 10; // Default zoom level if no valid points
    }

    final distances = [
      for (int i = 0; i < locations.length; i++)
        for (int j = i + 1; j < locations.length; j++)
          _calculateDistance(
            LatLng(locations[i]['latitude'], locations[i]['longitude']),
            LatLng(locations[j]['latitude'], locations[j]['longitude']),
          ),
    ];

    double maxDistance =
        distances.isNotEmpty ? distances.reduce((a, b) => a > b ? a : b) : 0;

    if (maxDistance <= 500) return 16;
    if (maxDistance <= 2000) return 14;
    if (maxDistance <= 5000) return 12;
    return 10;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const earthRadius = 6371000; // in meters
    final dLat = (point2.latitude - point1.latitude) * (pi / 180);
    final dLon = (point2.longitude - point1.longitude) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(point1.latitude * (pi / 180)) *
            cos(point2.latitude * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in meters
  }
}
