import 'package:flutter/material.dart';
import 'package:ghodaa/apis/socket.api.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/services/sound.service.dart';
// import 'package:ghodaa/services/navigator.service.dart';
import 'package:ghodaa/widgets/animated_search.widget.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:provider/provider.dart';

class RiderSearchScreen extends StatefulWidget {
  const RiderSearchScreen({super.key});

  @override
  _RiderSearchScreenState createState() => _RiderSearchScreenState();
}

class _RiderSearchScreenState extends State<RiderSearchScreen>
    with SingleTickerProviderStateMixin {
  late final SocketService socketService; // Declare SocketService

  @override
  void initState() {
    super.initState();

    // Retrieve MainState from the provider
    final mainState = Provider.of<MainState>(context, listen: false);

    // Initialize SocketService with MainState
    socketService = SocketService(mainState);
    socketService.init();

    // Listen for specific events
    socketService.listen(
      event: 'info',
      callback: (data) {
        print('INFO: $data');
      },
    );

    socketService.listen(
      event: 'warning',
      callback: (data) {
        print('WARNING: $data');
      },
    );

    socketService.listen(
      event: 'error',
      callback: (data) {
        print('ERROR: $data');
      },
    );

    // listen for 'riding' event
    socketService.listen(
      event: 'ride_ongoing',
      callback: (data) {
        print('RIDE_ONGOING: $data');
        // NavigatorService.navigateIfScreenNeedToChange(
        //   context,
        //   'DRIVER_SEARCH_SCREEN',
        //   data['screen'],
        // );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/pick_up_driver_screen',
          (Route<dynamic> route) => false, // Remove all previous routes
          arguments: {
            'rideId': data['rideId'],
          },
        );
      },
    );

    socketService.sendMessagePeriodic(
      channel: 'create_drive_request',
      message: {
        // Create ride request with pickup and drop-off locations
        'latitude': mainState.userLatitude,
        'longitude': mainState.userLongitude,
      },
      every: 1, // seconds
    );
  }

  @override
  void dispose() {
    socketService.disconnect();
    socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: true,
        child: Scaffold(
          backgroundColor: Colors.black, // Background color for the screen
          appBar: AppBar(
            foregroundColor: ColorService().white,
            title: Text('Searching for Riders'),
            backgroundColor: ColorService().black,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedSearchWidget(
                  color: ColorService().yellow,
                  size: 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Cancel Ride Button
                    Expanded(
                      child: SizedBox(
                        height: 64.0,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18.0),
                            backgroundColor: ColorService().red,
                            foregroundColor: ColorService().white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            SoundService.playOfflineSound();
                            socketService.sendMessage(
                              channel: 'delete_drive_request',
                              message: {},
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Go Offline'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0), // Space between buttons
                    // More Ride Info Button
                    SizedBox(
                      height: 64.0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: ColorService().blackAccent,
                          foregroundColor: ColorService().grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => {},
                        child: Icon(Icons.info_outline,
                            color: ColorService().white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
