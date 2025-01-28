import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ghodaa/apis/maps.api.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/services/map_style.service.dart';
import 'package:ghodaa/services/sound.service.dart';
import 'package:ghodaa/widgets/border_fade_effect.widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A widget that allows users to pick a location on a map.
class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({super.key});

  @override
  _MapLocationPickerState createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late GoogleMapController _mapController; // Controller for Google Map
  static const LatLng _initialLocation =
      LatLng(37.7749, -122.4194); // Initial map location
  Map<String, dynamic>? _selectedLocation; // Currently selected location data
  List<Map<String, dynamic>> _suggestions = []; // Search suggestions
  bool _isLoading = false; // Loading state for suggestions
  Timer? _debounce; // Timer for debounce functionality
  final FocusNode _searchFocusNode = FocusNode(); // Focus node for search field

  // Add a TextEditingController to control the search bar input
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void animateCameraToLatLong(double latitude, double longitude) {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _mapController
            .animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
      });
    });
  }

  // handle suggestion list item on tap event
  void _onTap(LatLng position) {
    SoundService.playClickSound();
    setState(() {
      _selectedLocation = {
        'coordinates': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'name': '',
        'vicinity': '',
        'description': '',
        'place_id': '',
        'nearby_coordinates': '',
        'nearby_name': '',
        'nearby_vicinity': '',
        'nearby_description': '',
        'nearby_place_id': '',
      };
      _suggestions.clear(); // Clear suggestions when tapping on the map
      _searchController.clear(); // Clear the search bar
    });
    animateCameraToLatLong(position.latitude, position.longitude);
  }

  /// Confirms the selected location and pops it back to the previous screen.
  void _confirmLocation() {
    SoundService.playClickSound();
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      _showSnackbar('Please pick a location on the map!');
    }
  }

  /// Searches for locations based on the user input in the search field.
  void _searchLocation(String query) {
    if (query.isEmpty) {
      _clearSuggestions(); // Clear suggestions if the query is empty
      return;
    }

    // Debounce the search request
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      setState(() => _isLoading = true);
      try {
        final suggestions = await MapsApiService.getSuggestions(query);
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(suggestions);
          _isLoading = false;
        });
      } catch (e) {
        _handleError('Failed to fetch suggestions: ${e.toString()}');
      }
    });
  }

  /// Selects a suggestion from the list and updates the map.
  void _selectSuggestion(String placeId) async {
    SoundService.playClickSound();
    setState(() {
      _isLoading = true; // Start loading indicator for suggestion
      _suggestions.clear();
      _searchFocusNode.unfocus(); // Dismiss the keyboard
    });

    try {
      final locationDetail = await MapsApiService.getCoordinates(placeId);
      setState(() {
        _selectedLocation = locationDetail;
        _searchController.text = locationDetail['description'];
      });
      // Animate the camera to the selected location
      animateCameraToLatLong(
        locationDetail['coordinates']['latitude'],
        locationDetail['coordinates']['longitude'],
      );
    } catch (e) {
      _handleError('Failed to fetch location details: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator for suggestion
      });
    }
  }

  /// Clears the current suggestions.
  void _clearSuggestions() {
    setState(() {
      _suggestions.clear();
      _isLoading = false;
    });
  }

  /// Handles errors by showing a snackbar message.
  void _handleError(String message) {
    setState(() => _isLoading = false);
    _showSnackbar(message);
  }

  /// Displays a snackbar with a message.
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>?;

    String hintText = arguments?['hintText'] ?? 'Search for a location';
    BitmapDescriptor markerIconColor = arguments?['iconColor'] == 'green'
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: ColorService().black,
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onTapOutside: (event) => _searchFocusNode.unfocus(),
          onChanged: _searchLocation,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            hintStyle: TextStyle(color: ColorService().grey),
          ),
          style: TextStyle(color: ColorService().white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorService().white),
          onPressed: () => {
            SoundService.playClickSound(),
            Navigator.pop(context),
          },
        ),
        actions: <Widget>[
          if (_selectedLocation != null && !_isLoading)
            TextButton(
              onPressed: _confirmLocation,
              child:
                  Text('NEXT', style: TextStyle(color: ColorService().green)),
            ),
        ],
      ),
      body: Stack(
        children: [
          BorderFadeEffect(
            child: GoogleMap(
              // style: MapStyle.dark,
              style: MapStyle.roadOnly,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition:
                  CameraPosition(target: _initialLocation, zoom: 17.0),
              onTap: _onTap,
              markers: _selectedLocation == null
                  ? {} // No markers if no location is selected
                  : {
                      Marker(
                        markerId: MarkerId('chosen_location'),
                        position: LatLng(
                          _selectedLocation!['coordinates']['latitude'],
                          _selectedLocation!['coordinates']['longitude'],
                        ),
                        infoWindow: InfoWindow(title: 'Chosen Location'),
                        icon: markerIconColor,
                      ),
                    },
            ),
          ),
          if (_isLoading)
            SizedBox(
              height: 2.0,
              child: LinearProgressIndicator(
                backgroundColor: ColorService().black,
                color: ColorService().yellow,
              ),
            ),
          if (_suggestions.isNotEmpty) _buildSuggestionList(),
        ],
      ),
    );
  }

  /// Builds a list of search suggestions.
  Widget _buildSuggestionList() {
    return Positioned(
      top: 2,
      left: 0,
      right: 0,
      child: Container(
        color: ColorService().black,
        child: ListView.separated(
          itemCount: _suggestions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return Divider(height: 1, color: ColorService().blackAccent);
          },
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return ListTile(
              leading: Icon(Icons.place, color: ColorService().grey),
              textColor: ColorService().white,
              title: Text(
                suggestion['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                _selectSuggestion(suggestion['place_id']);
              },
            );
          },
        ),
      ),
    );
  }
}
