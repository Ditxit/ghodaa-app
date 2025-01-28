import 'package:flutter/material.dart';
import 'package:ghodaa/apis/socket.api.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/services/sound.service.dart';
import 'package:ghodaa/widgets/animated_search.widget.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:provider/provider.dart';

class DriverSearchScreen extends StatefulWidget {
  const DriverSearchScreen({super.key});

  @override
  _DriverSearchScreenState createState() => _DriverSearchScreenState();
}

class _DriverSearchScreenState extends State<DriverSearchScreen>
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
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/pick_up_rider_screen',
          (Route<dynamic> route) => false, // Remove all previous routes
          arguments: {
            'rideId': data['rideId'],
          },
        );
      },
    );

    // create 'search' event
    socketService.sendMessagePeriodic(
      channel: 'create_ride_request',
      message: {
        'pickLatitude': mainState.pickUpLatitude,
        'pickLongitude': mainState.pickUpLongitude,
        'dropLatitude': mainState.dropOffLatitude,
        'dropLongitude': mainState.dropOffLongitude
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
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            foregroundColor: ColorService().white,
            title: Text('Finding Ride'),
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
              _customTile(
                icon: Icons.currency_rupee_rounded,
                iconColor: ColorService().grey,
                title: 'NRs. 232',
                titleColor: Colors.white,
                subtitle: 'Total Fare',
                subtitleColor: ColorService().grey,
              ),
              _customTile(
                icon: Icons.route_rounded,
                iconColor: ColorService().grey,
                title: '43 km',
                titleColor: Colors.white,
                subtitle: 'Travel Distance',
                subtitleColor: ColorService().grey,
              ),
              _customTile(
                icon: Icons.trip_origin_rounded,
                iconColor: ColorService().green,
                title: '39440 Parkhurst Dr, Fremont, CA',
                titleColor: Colors.white,
                subtitle: 'Pick Up',
                subtitleColor: ColorService().grey,
              ),
              _customTile(
                icon: Icons.place_rounded,
                iconColor: ColorService().red,
                title: '60 Wilson Way, Milpitas, CA',
                titleColor: Colors.white,
                subtitle: 'Drop Off',
                subtitleColor: ColorService().grey,
              ),
              _buildCancelFindDriveButton(context, socketService),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _customTile({
  IconData? icon,
  Color? iconColor,
  required String title,
  required Color titleColor,
  required String subtitle,
  required Color subtitleColor,
}) {
  return ListTile(
    leading: (icon != null)
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Icon(icon, size: 28, color: iconColor),
          )
        : SizedBox.shrink(),
    title: Text(
      subtitle,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: subtitleColor,
      ),
    ),
    subtitle: Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        color: titleColor,
      ),
    ),
  );
}

Widget _buildCancelFindDriveButton(
  BuildContext context,
  SocketService socketService,
) {
  return Padding(
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
              onPressed: () => {
                SoundService.playOfflineSound(),
                socketService
                    .sendMessage(channel: 'delete_ride_request', message: {}),
                Navigator.pop(context),
              },
              child: const Text('Cancel Ride'),
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
            child: Icon(Icons.info_outline, color: ColorService().white),
          ),
        ),
      ],
    ),
  );
}
