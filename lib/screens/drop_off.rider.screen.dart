import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:ghodaa/apis/socket.api.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/services/location.service.dart';
import 'package:ghodaa/services/navigator.service.dart';
import 'package:ghodaa/services/sound.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:ghodaa/widgets/animated_search.widget.dart';
import 'package:ghodaa/widgets/custom_google_map.widget.dart';
import 'package:provider/provider.dart';

class DropOffRiderScreen extends StatefulWidget {
  final String rideId;

  const DropOffRiderScreen({super.key, required this.rideId});

  @override
  _DropOffRiderScreenState createState() => _DropOffRiderScreenState();
}

class _DropOffRiderScreenState extends State<DropOffRiderScreen> {
  late SocketService socketService; // Socket service instance
  Map<String, dynamic>? _rideDetails; // To store ride details

  String? _distance;
  String? _distanceUnit;
  Map<String, String> _markerLocations = {};
  String _polyline = '';

  @override
  void initState() {
    super.initState();

    // Retrieve MainState from the provider
    final mainState = Provider.of<MainState>(context, listen: false);

    // Initialize SocketService with MainState
    socketService = SocketService(mainState);
    socketService.init();

    // listen for 'ride_terminate' event
    socketService.listen(
      event: 'ride_terminate',
      callback: (data) {
        print('RIDE_TERMINATE: $data');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home_screen',
          (Route<dynamic> route) => false, // Remove all previous routes
          arguments: {
            'message': 'Ride got cancelled',
          },
        );
      },
    );

    socketService.ping();
    socketService.pong((data) {
      print('RIDE_ONGOING: $data');

      NavigatorService.navigateIfScreenNeedToChange(
        context,
        ['RIDER_DROP_OFF_SCREEN'],
        data['screen']!,
      );

      Map<String, String> distanceInfo = LocationService.getDistance(
        mainState.userLatitude!,
        mainState.userLongitude!,
        data!['dropLatitude']!,
        data!['dropLongitude']!,
      );
      setState(() {
        _rideDetails = data!;
        _distance = distanceInfo['distance'];
        _distanceUnit = distanceInfo['unit'];
        _markerLocations = {
          'Driver Location':
              '${data!['driverLatitude']!},${data!['driverLongitude']!}',
          'Drop Off Location':
              '${data!['dropLatitude']!},${data!['dropLongitude']!}',
        };
        _polyline = data!['polylinePickToDrop'] ?? '';
      });
    });
  }

  @override
  void dispose() {
    socketService.disconnect(); // Disconnect socket service on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _rideDetails == null
        ? AnimatedSearchWidget(
            color: ColorService().yellow,
            size: 200,
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            // extendBodyBehindAppBar: true,
            // extendBody: true,
            appBar: AppBar(
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              leading: SizedBox(
                height: 44.0, // Height of the circular button
                width: 44.0, // Width of the circular button
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(24), // Circular effect for InkWell
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      shape:
                          BoxShape.circle, // Ensure the container is circular
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chat_rounded,
                        color: ColorService().grey, // Icon color
                        size: 24, // Icon size
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                SizedBox(
                  height: 44.0, // Height of the circular button
                  width: 44.0, // Width of the circular button
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                        24), // Circular effect for InkWell
                    onTap: () {
                      socketService
                          .sendMessage(channel: 'ride_terminate', message: {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape:
                            BoxShape.circle, // Ensure the container is circular
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: ColorService().grey, // Icon color
                          size: 24, // Icon size
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              title: AnimatedTextKit(
                repeatForever: true,
                pause: Duration(microseconds: 100),
                animatedTexts: [
                  FadeAnimatedText(
                    'Waiting for drop off',
                    duration: Duration(seconds: 4),
                    fadeOutBegin: 0.9,
                    fadeInEnd: 0.1,
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FadeAnimatedText(
                    'Drop off is $_distance $_distanceUnit away',
                    duration: Duration(seconds: 4),
                    fadeOutBegin: 0.9,
                    fadeInEnd: 0.1,
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FadeAnimatedText(
                    'Show PIN and drop',
                    duration: Duration(seconds: 4),
                    fadeOutBegin: 0.9,
                    fadeInEnd: 0.1,
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.transparent,
                  child: SafeArea(
                    maintainBottomViewPadding: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 12.0,
                        right: 12.0,
                        bottom: 0.0,
                        left: 12.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56.0,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                  backgroundColor: ColorService().green,
                                  foregroundColor: ColorService().white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => {
                                  SoundService.playClickSound(),
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: Colors.transparent,
                                      title: Text(
                                        _rideDetails!['dropOffPin']!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 40.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    barrierDismissible: true,
                                  )
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pin_rounded,
                                      size: 24.0,
                                      color: ColorService().white,
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Text('Show PIN'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0), // Space between buttons
                          Expanded(
                            child: SizedBox(
                              height: 56.0,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  textStyle: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                  backgroundColor: ColorService().blackAccent,
                                  foregroundColor: ColorService().grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  SoundService.playClickSound();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_rounded,
                                      size: 24.0,
                                      color: ColorService().grey,
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Text('Message'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: CustomGoogleMap(
                      initialLocation: '37.7749,-122.4194',
                      markerLocations: _markerLocations,
                      markerImages: {
                        'Driver Location': 'assets/icons/bike.png',
                        'Drop Off Location': 'assets/icons/drop.png',
                      },
                      polylinePoints: _polyline,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
