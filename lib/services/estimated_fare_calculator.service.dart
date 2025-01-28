import 'dart:math';

class EstimatedFareCalculatorService {
  /// Estimates the fare based on the distance between locations.
  ///
  /// Requires at least two locations with latitude and longitude, fare per kilometer,
  /// a breakpoint for distance, and a multiplier for fare if the distance exceeds the breakpoint.
  ///
  /// Parameters:
  /// - [locations]: A list of maps where each map contains 'lat' and 'lng' keys.
  /// - [farePerKm]: The fare charged per kilometer.
  /// - [breakpointKm]: The distance at which a higher fare is charged.
  /// - [inflationMultiplierOnBreakpoint]: The multiplier applied to the fare when the distance exceeds the breakpoint.
  ///
  /// Returns the estimated fare for the trip rounded up to the nearest whole number.
  ///
  /// Throws [ArgumentError] if the input is invalid.
  int estimateFare({
    required List<Map<String, double>> locations,
    required double farePerKm,
    required double breakpointKm,
    required double inflationMultiplierOnBreakpoint,
  }) {
    if (locations.length < 2) {
      throw ArgumentError('At least two locations are required to calculate fare.');
    }

    final firstLocation = locations.first;
    final lastLocation = locations.last;

    // Validate latitude and longitude for the provided locations
    validateCoordinates(firstLocation);
    validateCoordinates(lastLocation);

    final totalKm = calculateDistance(
      firstLocation['lat']!,
      firstLocation['lng']!,
      lastLocation['lat']!,
      lastLocation['lng']!,
    );

    if (totalKm < 0) {
      throw ArgumentError('Total kilometers must be non-negative.');
    }

    // Base fare calculation
    double estimatedFare = farePerKm * totalKm;

    // Apply inflation multiplier if the distance exceeds the breakpoint
    if (totalKm > breakpointKm) {
      estimatedFare *= inflationMultiplierOnBreakpoint;
    }

    // Round up the fare and return as an integer
    return estimatedFare.ceil().toInt();
  }

  /// Validates the coordinates of a location.
  ///
  /// Parameters:
  /// - [location]: A map containing 'lat' and 'lng' keys.
  ///
  /// Throws [ArgumentError] if the latitude or longitude is out of range.
  void validateCoordinates(Map<String, double> location) {
    final lat = location['lat'];
    final lng = location['lng'];
    if (lat == null || lng == null || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw ArgumentError('Invalid latitude or longitude values.');
    }
  }

  /// Calculates the distance between two points using the Haversine formula.
  ///
  /// Parameters:
  /// - [lat1], [lng1]: Latitude and longitude of the first point.
  /// - [lat2], [lng2]: Latitude and longitude of the second point.
  ///
  /// Returns the distance between the two points in kilometers.
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = degreesToRadians(lat2 - lat1);
    double dLng = degreesToRadians(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  /// Converts degrees to radians.
  ///
  /// Parameters:
  /// - [degrees]: The value in degrees to be converted.
  ///
  /// Returns the value in radians.
  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
