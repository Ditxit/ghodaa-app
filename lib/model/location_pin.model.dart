class LocationPin {
  // Place properties
  double? latitude;
  double? longitude;
  String? name;
  String? vicinity;
  String? description;
  String? placeId;

  // Nearby location as a nested LocationPin object
  LocationPin? nearby;

  LocationPin({
    this.latitude,
    this.longitude,
    this.name,
    this.vicinity,
    this.description,
    this.placeId,
    this.nearby,
  });

  // Getter methods for all fields
  double? getLatitude() => latitude;
  double? getLongitude() => longitude;

  String? getName() => name;
  String? getVicinity() => vicinity;
  String? getDescription() => description;
  String? getPlaceId() => placeId;

  // Getter for nearby LocationPin
  LocationPin? getNearby() => nearby;

  // Check if latitude and longitude are set
  bool isSet() => latitude != null && longitude != null;

  // Reset method to set all properties to null
  void reset() {
    latitude = null;
    longitude = null;
    name = null;
    vicinity = null;
    description = null;
    placeId = null;
    nearby = null; // Reset nearby to null
  }

  // Copy from another LocationPin instance
  void copyFrom(LocationPin other) {
    latitude = other.latitude;
    longitude = other.longitude;
    name = other.name;
    vicinity = other.vicinity;
    description = other.description;
    placeId = other.placeId;

    // If nearby exists, create a new LocationPin and copy values
    if (other.nearby != null) {
      nearby = LocationPin();
      nearby!
          .copyFrom(other.nearby!); // Ensure nearby is not null before copying
    } else {
      nearby = null; // Set nearby to null if it doesn't exist
    }
  }

  // Duplicate method that returns a new instance
  LocationPin duplicate() {
    return LocationPin(
      latitude: latitude,
      longitude: longitude,
      name: name,
      vicinity: vicinity,
      description: description,
      placeId: placeId,
      nearby: nearby?.duplicate(), // Duplicate nearby if it exists
    );
  }
}

// // Example usage
// void main() {
//   final nearbyLocation = LocationPin(
//     latitude: 40.7128,
//     longitude: -74.0060,
//     name: "Nearby Place",
//     vicinity: "Near Vicinity",
//     description: "Description of nearby place",
//     placeId: "nearbyPlaceId123",
//   );

//   final location1 = LocationPin(
//     latitude: 40.73061,
//     longitude: -73.935242,
//     name: "Main Place",
//     vicinity: "Main Vicinity",
//     description: "Description of main place",
//     placeId: "placeId123",
//     nearby: nearbyLocation,
//   );

//   // Accessing properties using getter methods
//   print('Location Name: ${location1.getName()}');
//   print('Nearby Location Name: ${location1.getNearby()?.getName()}');
//   print('Nearby Latitude: ${location1.getNearby()?.getLatitude()}');
//   print('Nearby Longitude: ${location1.getNearby()?.getLongitude()}');
// }
