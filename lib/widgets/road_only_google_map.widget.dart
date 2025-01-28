import 'package:flutter/material.dart';
import 'package:ghodaa/apis/maps.api.dart';
import 'package:ghodaa/services/map_style.service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ghodaa/states/main.state.dart';

class RoadOnlyGoogleMap extends StatefulWidget {
  const RoadOnlyGoogleMap({super.key});

  @override
  _RoadOnlyGoogleMapState createState() => _RoadOnlyGoogleMapState();
}

class _RoadOnlyGoogleMapState extends State<RoadOnlyGoogleMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<LatLng> _pathPoints = []; // Store path points

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the map controller if it's not null
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    final LatLng initialLocation =
        LatLng(mainState.userLatitude!, mainState.userLongitude!);
    _updateMarkers(mainState);

    return GoogleMap(
      style: MapStyle.roadOnly,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      minMaxZoomPreference: MinMaxZoomPreference(1, 19),
      onMapCreated: _onMapCreated,
      onTap: (coordinates) => _moveCameraToFitMarkers(),
      initialCameraPosition: CameraPosition(
        // target: widget.initialLocation,
        target: initialLocation,
        zoom: 16.0,
      ),
      markers: _markers,
      polylines: _buildPolylines(),
    );
  }

  Set<Polyline> _buildPolylines() {
    // Only add polyline if there are more than 1 marker
    if (_markers.length > 1) {
      return {
        Polyline(
          jointType: JointType.round,
          polylineId: PolylineId('route'),
          points: _pathPoints,
          color: Colors.white,
          width: 5,
        ),
      };
    }
    return {}; // Return empty set if there are fewer than 2 markers
  }

  void _updateMarkers(MainState mainState) {
    Set<Marker> markers = {};

    // Add pickup location marker
    if (mainState.isPickUpLocationSet()) {
      String pickupMarkerId =
          'pickup_${mainState.pickUpLatitude!.toStringAsFixed(6)}_${mainState.pickUpLongitude!.toStringAsFixed(6)}';
      markers.add(
        Marker(
          markerId: MarkerId(pickupMarkerId),
          position:
              LatLng(mainState.pickUpLatitude!, mainState.pickUpLongitude!),
          infoWindow: InfoWindow(title: 'Pick Up Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Add drop-off location marker
    if (mainState.isDropOffLocationSet()) {
      String dropoffMarkerId =
          'dropoff_${mainState.dropOffLatitude!.toStringAsFixed(6)}_${mainState.dropOffLongitude!.toStringAsFixed(6)}';
      markers.add(
        Marker(
          markerId: MarkerId(dropoffMarkerId),
          position:
              LatLng(mainState.dropOffLatitude!, mainState.dropOffLongitude!),
          infoWindow: InfoWindow(title: 'Drop Off Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Check if the marker sets are different
    if (_markers.length != markers.length ||
        !markers.every((newMarker) => _markers.any((oldMarker) =>
            oldMarker.markerId.value == newMarker.markerId.value))) {
      setState(() {
        _markers = markers;
      });

      // Fetch directions if both pickup and drop-off locations are set
      if (mainState.isPickUpLocationSet() && mainState.isDropOffLocationSet()) {
        _fetchDirections(
          mainState.pickUpLatitude!,
          mainState.pickUpLongitude!,
          mainState.dropOffLatitude!,
          mainState.dropOffLongitude!,
        );
      }

      // Move the camera to fit the markers if they change
      _moveCameraToFitMarkers();
    }
  }

  Future<void> _fetchDirections(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    try {
      final path = await MapsApiService.getPathPolygon(
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
      );
      setState(() {
        _pathPoints = path; // Update the path points
      });
    } catch (e) {
      print('Error fetching directions: $e'); // Handle errors appropriately
    }
  }

  void _moveCameraToFitMarkers() {
    if (_markers.isEmpty) return;

    if (_markers.length < 2) {
      final center = _markers.first.position;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(center, 16));
    } else {
      LatLngBounds bounds = _calculateBounds(_markers);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 120));
    }
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double? north, south, east, west;

    for (var marker in markers) {
      if (north == null || marker.position.latitude > north) {
        north = marker.position.latitude;
      }
      if (south == null || marker.position.latitude < south) {
        south = marker.position.latitude;
      }
      if (east == null || marker.position.longitude > east) {
        east = marker.position.longitude;
      }
      if (west == null || marker.position.longitude < west) {
        west = marker.position.longitude;
      }
    }

    return LatLngBounds(
      northeast: LatLng(north!, east!),
      southwest: LatLng(south!, west!),
    );
  }
}
