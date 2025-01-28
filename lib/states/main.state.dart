import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ghodaa/services/location.service.dart';

class MainState extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  MainState() {
    _initializeLocationUpdates();
  }

  // State Variables
  int _progressStep = 0;
  double _totalFare = 0;
  String _screenTitleText = 'Choose a Location';

  double? _customerLatitude;
  double? _customerLongitude;

  String? _pickUpLocationName;
  String? get pickUpLocationName => _pickUpLocationName;

  double? _pickUpLatitude;
  double? _pickUpLongitude;

  String? _dropOffLocationName;
  String? get dropOffLocationName => _dropOffLocationName;

  double? _dropOffLatitude;
  double? _dropOffLongitude;

  // Driver location variables
  double? _driverLatitude;
  double? _driverLongitude;

  // User Identifier Variable
  String? _userId;
  String? get userId => _userId;
  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  String? _userToken;
  String? get userToken => _userToken;
  void setUserToken(String token) {
    _userToken = token;
    notifyListeners();
  }

  String? _userType;
  String? get userType => _userType;
  bool isUserADriver() => _userType == 'driver';
  bool isUserARider() => _userType == 'rider';
  void setUserType(String type) {
    _userType = type;
    notifyListeners();
  }

  // User Info Variable
  String? _userFullName;
  String? get userFullName => _userFullName;
  void setUserFullName(String name) {
    _userFullName = name;
    notifyListeners();
  }

  String? _userProfilePictureURL;
  String? get userProfilePictureURL => _userProfilePictureURL;

  String? _userDescription;
  String? get userDescription => _userDescription;
  void setUserDescription(String description) {
    _userDescription = description;
    notifyListeners();
  }

  // User Location Variables
  double? _userLatitude;
  double? get userLatitude => _userLatitude;

  double? _userLongitude;
  double? get userLongitude => _userLongitude;

  String? _userLocationName;
  String? get userLocationName => _userLocationName;

  bool isUserLocationSet() => _userLatitude != null && _userLongitude != null;

  void setUserLocation(String name, double latitude, double longitude) {
    _userLocationName = name;
    _userLatitude = latitude;
    _userLongitude = longitude;
    notifyListeners();
  }

  void resetUserLocation() {
    _userLocationName = null;
    _userLatitude = null;
    _userLongitude = null;
    notifyListeners();
  }

  void setPickUpLocationAsUserLocation() {
    if (isUserLocationSet()) {
      setPickUpLocation(_userLocationName!, _userLatitude!, _userLongitude!);
      // notifyListeners();
    }
  }

  // Profile Variables
  String? _customerProfilePictureURL;
  String? _driverProfilePictureURL;
  String? _customerFullName;
  String? _customerDescription;
  String? _driverFullName;
  String? _driverDescription;

  // Estimated Values
  double? _estimatedFare;
  double? _estimatedKm;
  double? _estimatedTime; // in minutes

  // UI
  bool _recommendationIsVisible = false;
  // bool get recommendationIsVisible => _recommendationIsVisible;
  void setRecommendationVisibility(bool visible) {
    _recommendationIsVisible = visible;
    notifyListeners();
  }

  bool isRecommendationVisible() => _recommendationIsVisible;

  // Getters for location variables
  double? get customerLatitude => _customerLatitude;
  double? get customerLongitude => _customerLongitude;
  double? get pickUpLatitude => _pickUpLatitude;
  double? get pickUpLongitude => _pickUpLongitude;
  double? get dropOffLatitude => _dropOffLatitude;
  double? get dropOffLongitude => _dropOffLongitude;
  double? get driverLatitude => _driverLatitude;
  double? get driverLongitude => _driverLongitude;

  // Getters for profile variables
  String get customerProfilePictureURL => _customerProfilePictureURL ?? '';
  String get driverProfilePictureURL => _driverProfilePictureURL ?? '';
  String? get customerFullName => _customerFullName;
  String? get customerDescription => _customerDescription;
  String? get driverFullName => _driverFullName;
  String? get driverDescription => _driverDescription;

  // Getters for estimated values
  double? get estimatedFare => _estimatedFare;
  double? get estimatedKm => _estimatedKm;
  double? get estimatedTime => _estimatedTime;

  // Getters for other state variables
  int get progressStep => _progressStep;
  double get totalFare => _totalFare;
  String get screenTitleText => _screenTitleText;

  // Check methods
  bool isCustomerLocationSet() =>
      _customerLatitude != null && _customerLongitude != null;

  bool isPickUpLocationSet() =>
      _pickUpLatitude != null && _pickUpLongitude != null;

  bool isDropOffLocationSet() =>
      _dropOffLatitude != null && _dropOffLongitude != null;

  bool isDriverLocationSet() =>
      _driverLatitude != null && _driverLongitude != null;

  // Reset methods
  /// Resets the customer's location and notifies listeners.
  void resetCustomerLocation() {
    _customerLatitude = null;
    _customerLongitude = null;
    notifyListeners();
  }

  /// Resets the pick-up location and notifies listeners.
  void resetPickUpLocation() {
    _pickUpLocationName = null;
    _pickUpLatitude = null;
    _pickUpLongitude = null;
    notifyListeners();
  }

  /// Resets the drop-off location and notifies listeners.
  void resetDropOffLocation() {
    _dropOffLocationName = null;
    _dropOffLatitude = null;
    _dropOffLongitude = null;
    notifyListeners();
  }

  /// Resets the driver's location and notifies listeners.
  void resetDriverLocation() {
    _driverLatitude = null;
    _driverLongitude = null;
    notifyListeners();
  }

  /// Resets the estimated fare, kilometers, and time.
  void resetEstimates() {
    _estimatedFare = null;
    _estimatedKm = null;
    _estimatedTime = null;
    notifyListeners();
  }

  // Setter methods for estimated fare, kilometers, and time
  void setEstimatedFare(double fare) {
    _estimatedFare = fare;
    notifyListeners();
  }

  void setEstimatedKm(double kilometers) {
    _estimatedKm = kilometers;
    notifyListeners();
  }

  void setEstimatedTime(double time) {
    _estimatedTime = time;
    notifyListeners();
  }

  /// Resets the specified location (customer, pick-up, drop-off, or driver).
  void resetLocation(String locationType) {
    switch (locationType) {
      case 'customer':
        resetCustomerLocation();
        break;
      case 'pickUp':
        resetPickUpLocation();
        break;
      case 'dropOff':
        resetDropOffLocation();
        break;
      case 'driver':
        resetDriverLocation();
        break;
      default:
        print('Unknown location type');
    }
  }

  /// Sets the pick-up location as the customer's current location.
  void setPickUpLocationAsCurrent() {
    // depricated
    if (isCustomerLocationSet()) {
      _pickUpLocationName = _pickUpLocationName;
      _pickUpLatitude = _customerLatitude;
      _pickUpLongitude = _customerLongitude;
      notifyListeners();
    }
  }

  /// Updates the customer's location and notifies listeners.
  void setCustomerLocation(double latitude, double longitude) {
    _customerLatitude = latitude;
    _customerLongitude = longitude;
    notifyListeners();
  }

  /// Updates the pick-up location and notifies listeners.
  setPickUpLocation(
    String name,
    double latitude,
    double longitude,
  ) {
    if (name.isEmpty) {
      name = _locationService.getReadableLocationNameFromCurrentLocation(
        _userLatitude!,
        _userLongitude!,
        latitude,
        longitude,
      );
    }
    _pickUpLocationName = name;
    _pickUpLatitude = latitude;
    _pickUpLongitude = longitude;
    if (isPickUpLocationVeryCloseToUserLocation()) {
      _pickUpLocationName = 'Current Location';
    }
    notifyListeners();
  }

  /// Updates the pick-up location and notifies listeners.
  setDropOffLocation(
    String name,
    double latitude,
    double longitude,
  ) {
    if (name.isEmpty) {
      name = _locationService.getReadableLocationNameFromCurrentLocation(
        _userLatitude!,
        _userLongitude!,
        latitude,
        longitude,
      );
    }
    _dropOffLocationName = name;
    _dropOffLatitude = latitude;
    _dropOffLongitude = longitude;
    if (isDropOffLocationVeryCloseToUserLocation()) {
      _dropOffLocationName = 'Current Location';
    }
    notifyListeners();
  }

  /// Updates the driver's location and notifies listeners.
  void setDriverLocation(double latitude, double longitude) {
    _driverLatitude = latitude;
    _driverLongitude = longitude;
    notifyListeners();
  }

  /// Sets the customer's profile picture URL and notifies listeners.
  void setCustomerProfilePicture(String url) {
    _customerProfilePictureURL = url;
    notifyListeners();
  }

  /// Sets the driver's profile picture URL and notifies listeners.
  void setDriverProfilePicture(String url) {
    _driverProfilePictureURL = url;
    notifyListeners();
  }

  /// Sets the customer's name and description and notifies listeners.
  /// Sets the customer's name and description and notifies listeners.
  void setCustomerInfo(String name, String description) {
    _customerFullName = name;
    _customerDescription = description;
    notifyListeners();
  }

  /// Sets the driver's name and description and notifies listeners.
  void setDriverInfo(String name, String description) {
    _driverFullName = name;
    _driverDescription = description;
    notifyListeners();
  }

  /// Updates the current progress step and notifies listeners.
  void updateProgressStep(int step) {
    _progressStep = step;
    notifyListeners();
  }

  /// Advances to the next progress step and notifies listeners.
  void advanceProgressStep() {
    _progressStep++;
    notifyListeners();
  }

  /// Sets the total fare and notifies listeners.
  void setTotalFare(double fare) {
    _totalFare = fare;
    notifyListeners();
  }

  /// Sets the screen title text and notifies listeners.
  void setScreenTitleText(String title) {
    _screenTitleText = title;
    notifyListeners();
  }

  //
  bool isPickUpLocationVeryCloseToUserLocation() {
    if (!isPickUpLocationSet() || !isUserLocationSet()) return false;
    final double thresholdInMeters = 10; // Meters
    return _locationService.isCloseEnough(
      userLatitude!,
      userLongitude!,
      pickUpLatitude!,
      pickUpLongitude!,
      thresholdInMeters,
    );
  }

  bool isDropOffLocationVeryCloseToUserLocation() {
    if (!isDropOffLocationSet() || !isUserLocationSet()) return false;
    final double thresholdInMeters = 10; // Meters
    return _locationService.isCloseEnough(
      userLatitude!,
      userLongitude!,
      dropOffLatitude!,
      dropOffLongitude!,
      thresholdInMeters,
    );
  }

  /// Checks if the current pick-up location is close enough to the customer's location.
  ///
  /// This method compares the pick-up location and the customer location
  /// to determine if they are within a specified proximity threshold (50 meters).
  ///
  /// If either the pick-up or customer location is not set, the method returns `false`.
  /// Otherwise, it uses the `_locationService.isCloseEnough` method to calculate the distance
  /// between the two locations and returns `true` if they are within the threshold.
  ///
  /// Returns:
  ///   - `true` if the pick-up location is within the threshold distance from the customer's location.
  ///   - `false` if either location is not set or if they are not close enough.
  bool isPickUpLocationCloseEnoughToCustomerLocation() {
    if (!isPickUpLocationSet() || !isCustomerLocationSet()) {
      return false;
    }
    final double thresholdInMeters = 50; // Meters
    return _locationService.isCloseEnough(
      customerLatitude!,
      customerLongitude!,
      pickUpLatitude!,
      pickUpLongitude!,
      thresholdInMeters,
    );
  }

  /// Checks if the current pick-up location is close enough to the customer's location.
  ///
  /// This method compares the pick-up location and the customer location
  /// to determine if they are within a specified proximity threshold (50 meters).
  ///
  /// If either the pick-up or customer location is not set, the method returns `false`.
  /// Otherwise, it uses the `_locationService.isCloseEnough` method to calculate the distance
  /// between the two locations and returns `true` if they are within the threshold.
  ///
  /// Returns:
  ///   - `true` if the pick-up location is within the threshold distance from the customer's location.
  ///   - `false` if either location is not set or if they are not close enough.
  bool isDropOffLocationCloseEnoughToCustomerLocation() {
    if (!isDropOffLocationSet() || !isCustomerLocationSet()) {
      return false;
    }
    final double thresholdInMeters = 50; // Meters
    return _locationService.isCloseEnough(
      customerLatitude!,
      customerLongitude!,
      dropOffLatitude!,
      dropOffLongitude!,
      thresholdInMeters,
    );
  }

  /// Initializes location updates by checking permissions and starting location tracking.
  void _initializeLocationUpdates() async {
    try {
      bool hasPermission = await _locationService.checkPermission();
      if (hasPermission) {
        _locationService.startLocationUpdates((Position position) {
          setUserLocation(
            '${position.latitude},${position.longitude}',
            position.latitude,
            position.longitude,
          );
          if (!isPickUpLocationSet() ||
              isPickUpLocationVeryCloseToUserLocation()) {
            setPickUpLocationAsUserLocation();
          }

          // depricated
          setCustomerLocation(position.latitude, position.longitude);
          if (!isPickUpLocationSet()) setPickUpLocationAsCurrent();
        });
      } else {
        print('Location permission denied.');
      }
    } catch (e) {
      print('Error initializing location updates: $e');
    }
  }
}
