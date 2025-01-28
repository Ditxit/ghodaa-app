import 'package:flutter/material.dart';
import 'package:ghodaa/services/estimated_fare_calculator.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:provider/provider.dart';

class FindRide extends StatefulWidget {
  const FindRide({super.key});

  @override
  _FindRideState createState() => _FindRideState();
}

class _FindRideState extends State<FindRide> {
  final TextEditingController _dropOffController = TextEditingController();
  final TextEditingController _pickUpController =
      TextEditingController(text: 'Current Location');
  final FocusNode _dropOffFocusNode = FocusNode();
  final FocusNode _pickUpFocusNode = FocusNode();
  bool _showRecommendations = true;
  String _activeField = 'PickUp';
  int? _estimatedFare = 0;
  double? _totalKm = 0;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _locationRecommendations = [
    {
      'title': 'Current Location',
      'address': 'Use your GPS location',
      'icon': Icons.my_location,
      'isCurrentLocation': true
    },
    {
      'title': 'Choose on Map',
      'address': 'Select a location on the map',
      'icon': Icons.map,
      'isChooseOnMap': true
    },
    {
      'title': 'Home',
      'address': '39440 Parkhurst Dr, Fremont',
      'icon': Icons.home,
      'lat': 37.541990,
      'lng': -121.984980
    },
    {
      'title': 'Work',
      'address': '456 Corporate Ave, Your City',
      'icon': Icons.business,
      'lat': 40.7306,
      'lng': -73.9352
    },
    {
      'title': 'Friend’s House',
      'address': '789 Friend St, Your City',
      'icon': Icons.person,
      'lat': 40.6782,
      'lng': -73.9442
    },
    {
      'title': 'Nearest Airport',
      'address': 'Airport Road, Your City',
      'icon': Icons.airport_shuttle,
      'lat': 40.6413,
      'lng': -73.7781
    },
    {
      'title': 'Shopping Mall',
      'address': 'Mall Blvd, Your City',
      'icon': Icons.macro_off,
      'lat': 40.7561,
      'lng': -73.9872
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusCurrentStepField();
    });
  }

  void _focusCurrentStepField() {
    if (_currentStep == 0) {
      _pickUpFocusNode.requestFocus();
    } else if (_currentStep == 1) {
      _dropOffFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _dropOffController.dispose();
    _pickUpController.dispose();
    _dropOffFocusNode.dispose();
    _pickUpFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildLocationRecommendations() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey[900],
      height: _locationRecommendations.length * 80,
      child: ListView(
        children: _locationRecommendations.map((location) {
          return ListTile(
            title: Text(location['title'],
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
            subtitle: Text(location['address'],
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            leading: Icon(location['icon'], color: Colors.white, size: 28),
            onTap: () => _onLocationSelect(location),
          );
        }).toList(),
      ),
    );
  }

  void _onLocationSelect(Map<String, dynamic> location) {
    final mainState = Provider.of<MainState>(context, listen: false);
    if (location['isCurrentLocation'] == true) {
      if (_activeField == 'PickUp') {
        mainState.setPickUpLocationAsCurrent();
        print('${mainState.customerLatitude}, ${mainState.customerLongitude}');
        _pickUpController.text = 'Current Location';
        _showSnackBar('Using your current location');
      } else {
        mainState.setDropOffLocation(
          '${mainState.customerLatitude!},${mainState.customerLongitude!}',
          mainState.customerLatitude!,
          mainState.customerLongitude!,
        );
        _dropOffController.text = 'Current Location';
        _showSnackBar('Using your current location for drop-off');
      }
    } else if (location['isChooseOnMap'] == true) {
      _showSnackBar('Choose a location on the map');
    } else {
      _setLocation(mainState, location);
    }
    _updateEstimatedFare(mainState);
  }

  void _setLocation(MainState mainState, Map<String, dynamic> location) {
    if (_activeField == 'PickUp') {
      mainState.setPickUpLocation(
        '${location['lat']},${location['lng']}}',
        location['lat'],
        location['lng'],
      );
      _pickUpController.text = location['address'];
      _showSnackBar('Pick-up location changed to: ${location['address']}');
    } else {
      mainState.setDropOffLocation(
        '${location['lat']},${location['lng']}}',
        location['lat'],
        location['lng'],
      );
      _dropOffController.text = location['address'];
      _showSnackBar('Drop-off location changed to: ${location['address']}');
    }
  }

  void _updateEstimatedFare(MainState mainState) {
    if (_areLocationsSet(mainState)) {
      final fareCalculator = EstimatedFareCalculatorService();
      try {
        final locations = [
          {'lat': mainState.pickUpLatitude!, 'lng': mainState.pickUpLongitude!},
          {
            'lat': mainState.dropOffLatitude!,
            'lng': mainState.dropOffLongitude!
          },
        ];
        _estimatedFare = fareCalculator.estimateFare(
            locations: locations,
            farePerKm: 2.0,
            breakpointKm: 5.0,
            inflationMultiplierOnBreakpoint: 1.5);
        _totalKm = fareCalculator.calculateDistance(
            mainState.pickUpLatitude!,
            mainState.pickUpLongitude!,
            mainState.dropOffLatitude!,
            mainState.dropOffLongitude!);
      } catch (e) {
        _estimatedFare = null;
        _totalKm = null;
        _showSnackBar('Error calculating fare: ${e.toString()}');
      }
    } else {
      _estimatedFare = null;
      _totalKm = null;
    }
    setState(() {});
  }

  bool _areLocationsSet(MainState mainState) {
    return mainState.isPickUpLocationSet() && mainState.isDropOffLocationSet();
  }

  String _currentStepTitle() {
    if (_currentStep == 0) return 'Set pickup location';
    if (_currentStep == 1) return 'Set drop off location';
    if (_currentStep == 2) return 'Ride Summary';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<MainState>(
        builder: (context, mainState, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentStepTitle(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _handleNextStep(mainState);
                      },
                      child: Text(_currentStep < 2 ? 'Continue' : 'Find Ride'),
                    ),
                  ],
                ),
              ),
              if (_currentStep == 0) _buildPickUpStep(),
              if (_currentStep == 1) _buildDropOffStep(),
              if (_currentStep == 2) _buildSummaryStep(mainState),
              if (_showRecommendations) _buildLocationRecommendations(),
            ],
          );
        },
      ),
    );
  }

  void _handleNextStep(MainState mainState) {
    if (_currentStep == 0) {
      if (!mainState.isPickUpLocationSet()) {
        _showSnackBar('Please set your pick-up location.');
      } else {
        setState(() => _currentStep++);
        _focusCurrentStepField();
      }
    } else if (_currentStep == 1) {
      if (!mainState.isDropOffLocationSet()) {
        _showSnackBar('Please set your drop-off location.');
      } else {
        setState(() => _currentStep++);
        _focusCurrentStepField();
      }
    } else {
      if (!mainState.isPickUpLocationSet() ||
          !mainState.isDropOffLocationSet()) {
        _showSnackBar('Please set both pick-up and drop-off locations.');
      } else {
        setState(() => _showRecommendations = false);
        _showSnackBar('Ride booked!');
      }
    }
  }

  Widget _buildPickUpStep() {
    return Column(
      children: [
        _buildTextField(_pickUpController, 'From', 'PickUp', _pickUpFocusNode),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDropOffStep() {
    return Column(
      children: [
        _buildTextField(_dropOffController, 'To', 'DropOff', _dropOffFocusNode),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSummaryStep(MainState mainState) {
    return Column(
      children: [
        Text('From: ${_pickUpController.text}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        Text('To: ${_dropOffController.text}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        if (_estimatedFare != null && _totalKm != null)
          _buildFareAndDistanceCard(),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String fieldType, FocusNode focusNode) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[850],
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    if (fieldType == 'PickUp') {
                      Provider.of<MainState>(context, listen: false)
                          .resetPickUpLocation();
                    } else {
                      Provider.of<MainState>(context, listen: false)
                          .resetDropOffLocation();
                    }
                    _estimatedFare = null;
                    _totalKm = null;
                  });
                },
              )
            : null,
      ),
      focusNode: focusNode,
      onTap: () {
        setState(() {
          _showRecommendations = true;
          _activeField = fieldType;
        });
      },
    );
  }

  Widget _buildFareAndDistanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFareInfo(),
          _buildDistanceInfo(),
        ],
      ),
    );
  }

  Widget _buildFareInfo() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text('\Rs. ${_estimatedFare ?? '0'}',
            style: const TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const Text('Estimated Fare', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDistanceInfo() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text('${_totalKm?.toStringAsFixed(1) ?? '0.0'} km',
            style: const TextStyle(
                color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('Total Distance', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
