import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapLocationPickerService {
  // Store your API key securely, for example, using environment variables
  final String apiKey =
      'AIzaSyCrF14eC-3_dpkONl18_xHTwwG-CCiwVdU'; // Replace with your actual API key

  // Define constants for API endpoints
  static const String autocompleteEndpoint = 'place/autocomplete/json';
  static const String placeDetailsEndpoint = 'place/details/json';
  static const String nearbySearchEndpoint = 'place/nearbysearch/json';
  static const String directionsEndpoint = 'directions/json';

  Future<List<Map<String, dynamic>>> fetchSuggestions(String query) async {
    print('INFO: Fetch Suggestion API Called.');
    final response = await _get('$autocompleteEndpoint?input=$query');
    final predictions =
        json.decode(response.body)['predictions'] as List<dynamic>;

    return predictions
        .map((p) => {
              'description': p['description'],
              'place_id': p['place_id'],
            })
        .toList();
  }

  Future<Map<String, dynamic>> fetchCoordinates(String placeId) async {
    print('INFO: Fetch Coordinates API Called.');
    final response = await _get('$placeDetailsEndpoint?place_id=$placeId');
    final result = json.decode(response.body)['result'];
    final location = result['geometry']['location'];
    final latitude = location['lat'] as double;
    final longitude = location['lng'] as double;
    final name = result['name'];
    final vicinity = result['vicinity'];
    final description = result['formatted_address'];
    final placeIdReturned = result['place_id'];

    // Fetch nearby place
    final nearbyPlace = await fetchNearbyPlace(latitude, longitude);

    return {
      // Main details
      'coordinates': {'latitude': latitude, 'longitude': longitude},
      'name': name,
      'vicinity': vicinity,
      'description': description,
      'place_id': placeIdReturned,
      // Nearby details
      'nearby_coordinates': nearbyPlace['nearby_coordinates'],
      'nearby_name': nearbyPlace['nearby_name'],
      'nearby_vicinity': nearbyPlace['nearby_vicinity'],
      'nearby_description': nearbyPlace['nearby_description'],
      'nearby_place_id': nearbyPlace['nearby_place_id'],
    };
  }

  Future<Map<String, dynamic>> fetchNearbyPlace(
      double latitude, double longitude) async {
    print('INFO: Fetch NearBy API Called.');
    final response = await _get(
        '$nearbySearchEndpoint?location=$latitude,$longitude&radius=1000');

    final results = json.decode(response.body)['results'] as List<dynamic>;
    if (results.isNotEmpty) {
      final firstResult = results[0];
      final nearbyLocation = firstResult['geometry']['location'];

      final nearbyCoordinates = {
        'latitude': nearbyLocation['lat'] as double,
        'longitude': nearbyLocation['lng'] as double,
      };
      final nearbyName = firstResult['name'];
      final nearbyVicinity = firstResult['vicinity'];
      final nearbyDescription = firstResult['name']; // Consider refining this
      final nearbyPlaceId = firstResult['place_id'];

      return {
        'nearby_coordinates': nearbyCoordinates,
        'nearby_name': nearbyName,
        'nearby_vicinity': nearbyVicinity,
        'nearby_description': nearbyDescription,
        'nearby_place_id': nearbyPlaceId,
      };
    }

    throw Exception('No nearby places found');
  }

  Future<List<LatLng>> fetchPathPolygon(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) async {
    print('INFO: Fetch Path Polygon API Called.');
    final response = await _get(
        '$directionsEndpoint?origin=$startLatitude,$startLongitude&destination=$endLatitude,$endLongitude&key=$apiKey');

    final directions = json.decode(response.body);
    if (directions['status'] == 'OK') {
      final List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];
      List<LatLng> path = [];

      for (var step in steps) {
        final polyline = step['polyline']['points'];
        path.addAll(_decodePolyline(polyline));
      }
      return path;
    } else {
      throw Exception('Failed to fetch directions: ${directions['status']}');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result >> 1) ^ -(result & 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result >> 1) ^ -(result & 1));
      lng += dlng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return coordinates;
  }

  Future<http.Response> _get(String endpoint) async {
    final url = 'https://maps.googleapis.com/maps/api/$endpoint&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Error fetching data from API: ${response.reasonPhrase}');
    }

    return response;
  }
}
