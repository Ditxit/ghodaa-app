import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugging

class MapsApiService {
  // Base URL of the API
  static final String _baseUrl = dotenv.env['API_ENDPOINT'] ?? '';

  // Authorization Token
  static const String _authToken =
      'your_auth_token'; // Replace with your actual token

  // HTTP Headers including Authorization token
  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      };

  static List<LatLng> _parsePathFromString(String pathString) {
    // Split the string by commas and trim any whitespace
    List<String> coordinates =
        pathString.split(',').map((e) => e.trim()).toList();

    List<LatLng> pathPoints = [];

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
      pathPoints.add(LatLng(lat, lon));
    }

    return pathPoints;
  }

  // Get Location Suggestions
  static Future<List<dynamic>> getSuggestions(String query) async {
    final url = Uri.parse('$_baseUrl/maps/suggestions?query=$query');

    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('Error fetching suggestions: ${response.body}');
      throw Exception('Failed to fetch suggestions');
    }
  }

  // Get Coordinates for a Specific Place
  static Future<Map<String, dynamic>> getCoordinates(String placeId) async {
    final url = Uri.parse('$_baseUrl/maps/coordinates/$placeId');

    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('Error fetching coordinates: ${response.body}');
      throw Exception('Failed to fetch coordinates');
    }
  }

  // Get Nearby Places
  static Future<Map<String, dynamic>> getNearbyPlaces(
      double latitude, double longitude) async {
    final url = Uri.parse(
        '$_baseUrl/maps/nearby?latitude=$latitude&longitude=$longitude');

    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('Error fetching nearby places: ${response.body}');
      throw Exception('Failed to fetch nearby places');
    }
  }

  // Get Directions
  static Future<List<LatLng>> getPathPolygon({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    final url = Uri.parse(
        '$_baseUrl/maps/directions?startLatitude=$startLatitude&startLongitude=$startLongitude&endLatitude=$endLatitude&endLongitude=$endLongitude');

    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      // final body = jsonDecode(response.body);
      return _parsePathFromString(response.body);
      // return jsonDecode(response.body);
    } else {
      debugPrint('Error fetching directions: ${response.body}');
      throw Exception('Failed to fetch directions');
    }
  }
}
