import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final StreamController<Position> _positionController =
      StreamController<Position>();

  void startLocationUpdates(Function(Position) onUpdate) {
    // Start listening to location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
        // timeLimit:
      ),
    ).listen((Position position) {
      onUpdate(position); // Callback to update the location
    });
  }

  void stopLocationUpdates() {
    _positionController.close();
  }

  /// Checks and requests location permission.
  /// Returns true if permission is granted, otherwise false.
  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Gets the current position of the device.
  /// Returns the current position if permission is granted, otherwise null.
  Future<Position?> getCurrentPosition() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
    return null;
  }

  /// Gets the last known position of the device.
  /// Returns the last known position or null if not available.
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// Calculates the distance in meters between two geographic coordinates.
  double calculateDistanceInMeters(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }

  /// Calculates the distance and time to cover it based on speed.
  ///
  /// Returns a formatted string that includes both the distance in kilometers
  /// and the time required to travel that distance.
  String calculateDistanceAndTime(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
    double speed,
  ) {
    // Calculate distance
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    double distanceInKm = distanceInMeters / 1000; // Convert to kilometers

    // Format the distance to remove trailing zeros
    String formattedDistance =
        "${distanceInKm.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} km";

    // Validate speed
    if (speed <= 0) {
      throw ArgumentError("Speed must be greater than zero.");
    }

    // Calculate time
    double timeInHours = distanceInKm / speed; // Time in hours
    int totalSeconds = (timeInHours * 3600).toInt(); // Convert hours to seconds

    // Calculate days, hours, minutes, and seconds
    int days = totalSeconds ~/ 86400; // Seconds in a day
    int hours = (totalSeconds % 86400) ~/ 3600; // Remaining hours
    int minutes = (totalSeconds % 3600) ~/ 60; // Remaining minutes
    int seconds = totalSeconds % 60; // Remaining seconds

    // Create a list to hold parts of the time
    List<String> timeParts = [];
    if (days > 0) timeParts.add("$days day${days > 1 ? 's' : ''}");
    if (hours > 0) timeParts.add("$hours hour${hours > 1 ? 's' : ''}");
    if (minutes > 0) timeParts.add("$minutes min${minutes > 1 ? 's' : ''}");
    if (seconds > 0) timeParts.add("$seconds sec${seconds > 1 ? 's' : ''}");

    // Return formatted string with distance and time
    return "$formattedDistance (${timeParts.join(', ')})";
  }

  /// This function checks whether two sets of latitude and longitude coordinates are within a given threshold (in meters).
  /// You can adjust the thresholdInMeters value to define how close two locations need to be to be considered the same.
  bool isCloseEnough(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double thresholdInMeters,
  ) {
    const double earthRadius = 6371000; // Radius of the Earth in meters

    // Convert degrees to radians
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    // Haversine formula
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Distance between the two coordinates
    double distance = earthRadius * c;

    // Return true if distance is within the threshold
    return distance <= thresholdInMeters;
  }

  /// Returns a string describing the distance between the user's current location
  /// and a specified location.
  String getReadableLocationNameFromCurrentLocation(
    double userLatitude,
    double userLongitude,
    double targetLatitude,
    double targetLongitude,
  ) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      targetLatitude,
      targetLongitude,
    );

    double distanceInKm = distanceInMeters / 1000; // Convert to kilometers

    // Format the distance to remove trailing zeros
    String formattedDistance =
        distanceInKm.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

    return "$formattedDistance km away from your location.";
  }

  /// Returns a map containing the distance and its unit
  /// based on the distance between two geographical points.
  static Map<String, String> getDistance(
    double userLatitude,
    double userLongitude,
    double targetLatitude,
    double targetLongitude,
  ) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      targetLatitude,
      targetLongitude,
    );

    if (distanceInMeters > 1000) {
      // Greater than 1000 meters, return in kilometers
      double distanceInKm = distanceInMeters / 1000; // Convert to kilometers
      String formattedKm =
          distanceInKm.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return {'distance': formattedKm, 'unit': 'km'};
    } else {
      // Greater than 5 meters, return in meters
      String formattedMeters = distanceInMeters.round().toString();
      return {'distance': formattedMeters, 'unit': 'meter'};
    }
    // if (distanceInMeters > 1000) {
    //   // Greater than 1000 meters, return in kilometers
    //   double distanceInKm = distanceInMeters / 1000; // Convert to kilometers
    //   String formattedKm =
    //       distanceInKm.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    //   return {'distance': formattedKm, 'unit': 'km'};
    // } else if (distanceInMeters > 5) {
    //   // Greater than 5 meters, return in meters
    //   String formattedMeters = distanceInMeters.round().toString();
    //   return {'distance': formattedMeters, 'unit': 'meters'};
    // } else {
    //   // 5 meters or less, return in feet
    //   double distanceInFeet = distanceInMeters * 3.28084; // Convert to feet
    //   String formattedFeet = distanceInFeet.round().toString();
    //   return {'distance': formattedFeet, 'unit': 'feet'};
    // }
  }
}
