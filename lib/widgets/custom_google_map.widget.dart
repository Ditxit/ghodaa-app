import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:ghodaa/services/map_style.service.dart';
import 'package:ghodaa/services/marker_bitmap.service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatefulWidget {
  final Map<String, String> markerLocations;
  final String initialLocation;
  final Map<String, String> markerImages;
  final String? polylinePoints;

  const CustomGoogleMap({
    super.key,
    required this.markerLocations,
    required this.initialLocation,
    required this.markerImages,
    this.polylinePoints,
  });

  @override
  _CustomGoogleMapState createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  GoogleMapController? _mapController;
  double? _currentBearing;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isUserInteracting = false;
  Timer? _interactionTimer;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _listenToCompass();
  }

  void _initializeMap() async {
    await _loadMarkers();
    await _loadPolylines();
  }

  void _listenToCompass() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null && mounted) {
        setState(() {
          _currentBearing = event.heading!;
        });
      }
    });
  }

  Future<void> _loadMarkers() async {
    final markers = await Future.wait(
      widget.markerLocations.entries.map((entry) async {
        final position = _parseLatLng(entry.value);
        final imagePath =
            widget.markerImages[entry.key] ?? 'assets/icons/pick.png';
        final icon = await MarkerBitmapService.loadAssetBitmap(imagePath);

        return Marker(
          markerId: MarkerId(entry.key),
          position: position,
          infoWindow: InfoWindow(title: entry.key),
          icon: icon,
          anchor: Offset(0.5, 0.5),
        );
      }),
    );

    setState(() => _markers = markers.toSet());
  }

  static List<Polyline> getPolylineListFromString(String polyline) {
    // Split the string by commas and trim any whitespace
    List<String> coordinates =
        polyline.split(',').map((e) => e.trim()).toList();

    List<LatLng> points = [];
    List<Polyline> polylineList = [];

    // Check if we have an even number of elements (latitude, longitude pairs)
    if (coordinates.length % 2 != 0) {
      throw FormatException(
          'Path string must contain an even number of coordinates.');
    }

    for (int i = 0; i < coordinates.length; i += 2) {
      // Parse the latitude and longitude from the strings
      double lat = double.parse(coordinates[i]);
      double lon = double.parse(coordinates[i + 1]);

      // Create a LatLng object and add it to the path points
      points.add(LatLng(lat, lon));
    }

    if (points.isNotEmpty) {
      polylineList.add(Polyline(
        polylineId: PolylineId("polyline-1"),
        color: Colors.white,
        jointType: JointType.bevel,
        width: 10,
        zIndex: 100,
        points: points,
      ));
    }

    return polylineList;
  }

  Future<void> _loadPolylines() async {
    if (widget.polylinePoints == null || widget.polylinePoints!.isEmpty) {
      setState(() => _polylines = {});
      return;
    }
    // if (_isUserVeryCloseToPolylines()) return;
    // print('IMPORTANT_INFO: Polylines API called');

    final polylineList = getPolylineListFromString(widget.polylinePoints!);
    setState(() => _polylines = polylineList.toSet());
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCameraToInitialLocation();
  }

  void _moveCameraToInitialLocation() {
    if (_mapController == null) return;
    final initialLatLng = _parseLatLng(widget.initialLocation);
    _mapController!.animateCamera(CameraUpdate.newLatLng(initialLatLng));
    _moveCameraToFitEverything();
  }

  LatLng _parseLatLng(String latLngString) {
    final coordinates = latLngString.split(',');
    return LatLng(double.parse(coordinates[0]), double.parse(coordinates[1]));
  }

  void _moveCameraToFitEverything() async {
    if (_mapController == null || (_markers.isEmpty && _polylines.isEmpty)) {
      return;
    }

    final positions = widget.markerLocations.values.map(_parseLatLng).toList();
    for (var polyline in _polylines) {
      positions.addAll(polyline.points);
    }

    if (positions.isEmpty) return;

    final bounds = _calculateBoundsFromPositions(positions);
    if (positions.length == 1) {
      final targetCenter = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: targetCenter,
          zoom: 17,
          bearing: _currentBearing ?? 0,
        ),
      ));
    } else {
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 75));
    }
  }

  LatLngBounds _calculateBoundsFromPositions(List<LatLng> positions) {
    double? north, south, east, west;
    for (var position in positions) {
      if (north == null || position.latitude > north) north = position.latitude;
      if (south == null || position.latitude < south) south = position.latitude;
      if (east == null || position.longitude > east) east = position.longitude;
      if (west == null || position.longitude < west) west = position.longitude;
    }
    return LatLngBounds(
      northeast: LatLng(north!, east!),
      southwest: LatLng(south!, west!),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markerLocations != widget.markerLocations) _loadMarkers();
    if (oldWidget.polylinePoints != widget.polylinePoints) _loadPolylines();
    if (!_isUserInteracting) _moveCameraToFitEverything();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GoogleMap(
        style: MapStyle.roadOnly,
        onMapCreated: _onMapCreated,
        markers: _markers,
        polylines: _polylines,
        initialCameraPosition: CameraPosition(
          target: _parseLatLng(widget.initialLocation),
          zoom: 10,
        ),
        compassEnabled: false,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        onCameraMoveStarted: () {
          _interactionTimer?.cancel(); // Cancel any pending timer
          setState(() => _isUserInteracting = true);
        },
        onCameraIdle: () {
          _interactionTimer = Timer(Duration(seconds: 3), () {
            if (mounted) {
              setState(() => _isUserInteracting = false);
            }
          });
        },
        onLongPress: (_) => _moveCameraToFitEverything(),
        onTap: (_) => _moveCameraToFitEverything(),
      ),
    );
  }
}
