import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class NavigationMapWidget extends StatefulWidget {
  const NavigationMapWidget({super.key});

  @override
  _NavigationMapWidgetState createState() => _NavigationMapWidgetState();
}

class _NavigationMapWidgetState extends State<NavigationMapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final centerLocation = _calculateCenter(context);
    final zoomLevel = _calculateZoomLevel(context);

    // Move the map to the new center and zoom level
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(centerLocation, zoomLevel);
    });

    return SizedBox(
      // height: MediaQuery.of(context).size.height / 2,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: centerLocation,
          initialZoom: zoomLevel,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(markers: _buildMarkers(context)),
        ],
      ),
    );
  }

  LatLng _calculateCenter(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    final currentLocation = LatLng(
      mainState.customerLatitude ?? 0.0,
      mainState.customerLongitude ?? 0.0,
    );
    final pickupLocation = LatLng(
      mainState.pickUpLatitude ?? 0.0,
      mainState.pickUpLongitude ?? 0.0,
    );
    final dropOffLocation = LatLng(
      mainState.dropOffLatitude ?? 0.0,
      mainState.dropOffLongitude ?? 0.0,
    );

    // Use valid locations only for center calculation
    List<LatLng> validLocations = [
      currentLocation,
      pickupLocation,
      dropOffLocation
    ]
        .where(
            (location) => location.latitude != 0.0 && location.longitude != 0.0)
        .toList();

    if (validLocations.isEmpty) {
      return currentLocation; // Fallback to current location if no valid points
    }

    return LatLng(
      validLocations.map((loc) => loc.latitude).reduce((a, b) => a + b) /
          validLocations.length,
      validLocations.map((loc) => loc.longitude).reduce((a, b) => a + b) /
          validLocations.length,
    );
  }

  double _calculateZoomLevel(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    final currentLocation = LatLng(
      mainState.customerLatitude ?? 0.0,
      mainState.customerLongitude ?? 0.0,
    );
    final pickupLocation = LatLng(
      mainState.pickUpLatitude ?? 0.0,
      mainState.pickUpLongitude ?? 0.0,
    );
    final dropOffLocation = LatLng(
      mainState.dropOffLatitude ?? 0.0,
      mainState.dropOffLongitude ?? 0.0,
    );

    // Use valid locations only for distance calculation
    List<LatLng> validLocations = [
      currentLocation,
      pickupLocation,
      dropOffLocation
    ]
        .where(
            (location) => location.latitude != 0.0 && location.longitude != 0.0)
        .toList();

    if (validLocations.isEmpty) {
      return 10; // Default zoom level if no valid points
    }

    final distances = [
      if (validLocations.length > 1)
        _calculateDistance(validLocations[0], validLocations[1]),
      if (validLocations.length > 2)
        _calculateDistance(validLocations[0], validLocations[2]),
      if (validLocations.length > 1 && validLocations.length > 2)
        _calculateDistance(validLocations[1], validLocations[2]),
    ].where((distance) => distance > 0).toList();

    double maxDistance =
        distances.isNotEmpty ? distances.reduce((a, b) => a > b ? a : b) : 0;

    if (maxDistance <= 500) return 16;
    if (maxDistance <= 2000) return 14;
    if (maxDistance <= 5000) return 12;
    return 10;
  }

  List<Marker> _buildMarkers(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    final currentLocation = LatLng(
      mainState.customerLatitude ?? 0.0,
      mainState.customerLongitude ?? 0.0,
    );
    final pickupLocation = LatLng(
      mainState.pickUpLatitude ?? 0.0,
      mainState.pickUpLongitude ?? 0.0,
    );
    final dropOffLocation = LatLng(
      mainState.dropOffLatitude ?? 0.0,
      mainState.dropOffLongitude ?? 0.0,
    );

    List<Marker> markers = [];

    // Add marker for current location if valid
    if (currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0) {
      markers.add(
        Marker(
          point: currentLocation,
          child: _buildMarker(Icons.my_location, Colors.deepPurple),
        ),
      );
    }

    // Add marker for pickup location if valid
    if (pickupLocation.latitude != 0.0 && pickupLocation.longitude != 0.0) {
      markers.add(
        Marker(
          point: pickupLocation,
          child: _buildMarker(Icons.location_on, ColorService().green),
        ),
      );
    }

    // Add marker for drop-off location if valid
    if (dropOffLocation.latitude != 0.0 && dropOffLocation.longitude != 0.0) {
      markers.add(
        Marker(
          point: dropOffLocation,
          child: _buildMarker(Icons.flag, ColorService().red),
        ),
      );
    }

    return markers;
  }

  Widget _buildMarker(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            spreadRadius: 6,
            blurRadius: 12,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
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
