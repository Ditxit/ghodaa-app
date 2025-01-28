import 'package:flutter/material.dart';
import 'package:ghodaa/apis/socket.api.dart';
import 'package:ghodaa/screens/map_location_picker.screen.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/services/navigator.service.dart';
import 'package:ghodaa/services/sound.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:ghodaa/widgets/animated_search.widget.dart';
import 'package:ghodaa/widgets/border_fade_effect.widget.dart';
import 'package:ghodaa/widgets/custom_google_map.widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MapLocationPicker mapLocationPicker;
  late SocketService socketService; // Socket service instance
  Map<String, dynamic>? ride; // To store ride details

  @override
  void initState() {
    super.initState();
    mapLocationPicker = const MapLocationPicker();

    // Retrieve MainState from the provider
    final mainState = Provider.of<MainState>(context, listen: false);

    // Initialize SocketService with MainState
    socketService = SocketService(mainState);
    socketService.init();

    // ping/pong handler
    socketService.ping();
    socketService.pong((data) {
      print('RIDE_ONGOING: $data');

      NavigatorService.navigateIfScreenNeedToChange(
        context,
        ['RIDER_HOME_SCREEN', 'DRIVER_HOME_SCREEN'],
        data!['screen']!,
      );

      setState(() {
        ride = data;
      });
    });
  }

  @override
  void dispose() {
    socketService.disconnect(); // Disconnect socket service on dispose
    super.dispose();
  }

  Future<void> _navigateToPickUpLocationPicker() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final pickedLocation = await Navigator.pushNamed(
      context,
      '/map_location_picker',
      arguments: {'hintText': 'Search pickup location', 'iconColor': 'green'},
    );

    Navigator.of(context).pop(); // Close the loading dialog

    try {
      final location = pickedLocation as Map<String, dynamic>;
      final String name = location['name'] ?? location['nearby_name'];
      final double latitude = location['coordinates']['latitude'];
      final double longitude = location['coordinates']['longitude'];

      Provider.of<MainState>(context, listen: false)
          .setPickUpLocation(name, latitude, longitude);
    } catch (e) {
      print('No location selected or result is of unexpected type.');
    }
  }

  Future<void> _navigateToDropOffLocationPicker() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final pickedLocation = await Navigator.pushNamed(
      context,
      '/map_location_picker',
      arguments: {'hintText': 'Search drop off location', 'iconColor': 'red'},
    );

    Navigator.of(context).pop(); // Close the loading dialog

    try {
      final location = pickedLocation as Map<String, dynamic>;
      final String name = location['name'] ?? location['nearby_name'];
      final double latitude = location['coordinates']['latitude'];
      final double longitude = location['coordinates']['longitude'];

      Provider.of<MainState>(context, listen: false)
          .setDropOffLocation(name, latitude, longitude);
    } catch (e) {
      print('No location selected or result is of unexpected type.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ride == null
        ? AnimatedSearchWidget(
            color: ColorService().yellow,
            size: 200,
          )
        : Scaffold(
            // extendBody: true,
            // extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
              preferredSize: Size(double.infinity, 56.0),
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: ColorService().black,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            foregroundImage: NetworkImage(
                              'https://avatar.iran.liara.run/public/48',
                            ),
                            backgroundColor: ColorService().blackAccent,
                          ),
                          SizedBox(width: 12.0),
                          Consumer<MainState>(builder: (
                            context,
                            mainState,
                            child,
                          ) {
                            return Text(
                              '${mainState.userFullName}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          }),
                        ],
                      ),
                      Consumer<MainState>(builder: (
                        context,
                        mainState,
                        child,
                      ) {
                        return SizedBox(
                          width: 102,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: ColorService().blackAccent,
                                foregroundColor: ColorService().grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: mainState.isUserADriver()
                                  ? () => {
                                        SoundService.playOnlineSound(),
                                        Navigator.pushNamed(
                                          context,
                                          '/rider_search_screen',
                                        )
                                      }
                                  : () => {},
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Text('Drive'),
                                  ),
                                  Icon(
                                    mainState.isUserADriver()
                                        ? Icons.arrow_forward
                                        : Icons.lock,
                                    size: 22,
                                    color: ColorService().greyDark,
                                  )
                                ],
                              )),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Consumer<MainState>(
                        builder: (context, mainState, child) {
                      return BorderFadeEffect(
                        child: CustomGoogleMap(
                          initialLocation:
                              '${mainState.userLatitude!},${mainState.userLongitude!}',
                          markerLocations: {
                            if (mainState.isUserLocationSet() &&
                                !mainState.isPickUpLocationSet() &&
                                !mainState.isDropOffLocationSet())
                              'Your Location':
                                  '${mainState.userLatitude!},${mainState.userLongitude!}',
                            if (mainState.isPickUpLocationSet())
                              'Pick Up Location':
                                  '${mainState.pickUpLatitude!},${mainState.pickUpLongitude!}',
                            if (mainState.isDropOffLocationSet())
                              'Drop Off Location':
                                  '${mainState.dropOffLatitude!},${mainState.dropOffLongitude!}',
                          },
                          markerImages: {
                            'Your Location': 'assets/icons/you.png',
                            'Pick Up Location': 'assets/icons/pick.png',
                            'Drop Off Location': 'assets/icons/drop.png',
                          },
                          polylinePoints: (mainState.isPickUpLocationSet() &&
                                  mainState.isDropOffLocationSet())
                              ? '${mainState.pickUpLatitude!},${mainState.pickUpLongitude!},${mainState.dropOffLatitude!},${mainState.dropOffLongitude!}'
                              : '',
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Adjust height to content
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Consumer<MainState>(
                          builder: (context, mainState, child) {
                            return mainState.isPickUpLocationSet()
                                ? Icon(
                                    Icons.trip_origin_rounded,
                                    color: ColorService().green,
                                  )
                                : Icon(
                                    Icons.trip_origin_rounded,
                                    color: ColorService().grey,
                                  );
                          },
                        ),
                        title: Text('Pick Up'),
                        subtitle: Consumer<MainState>(
                          builder: (context, mainState, child) {
                            return mainState.isPickUpLocationSet()
                                ? Text(
                                    '${mainState.pickUpLocationName}',
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    'Choose a pick-up location in map',
                                    overflow: TextOverflow.ellipsis,
                                  );
                          },
                        ),
                        trailing: Consumer<MainState>(
                          builder: (context, mainState, child) {
                            return IconButton(
                              onPressed: () => {
                                SoundService.playClickSound(),
                                mainState.setPickUpLocationAsUserLocation(),
                              },
                              icon: Icon(Icons.my_location_rounded),
                              color: mainState
                                      .isPickUpLocationVeryCloseToUserLocation()
                                  ? ColorService().green
                                  : ColorService().grey,
                            );
                          },
                        ),
                        onTap: () => {
                          SoundService.playClickSound(),
                          _navigateToPickUpLocationPicker(),
                        },
                      ),
                      // Drop off
                      ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Consumer<MainState>(
                          builder: (context, mainState, child) {
                            return mainState.isDropOffLocationSet()
                                ? Icon(Icons.trip_origin_rounded,
                                    color: ColorService().red)
                                : Icon(Icons.trip_origin_rounded,
                                    color: ColorService().grey);
                          },
                        ),
                        title: Text('Drop Off'),
                        subtitle: Consumer<MainState>(
                          builder: (context, mainState, child) {
                            return mainState.isDropOffLocationSet()
                                ? Text(
                                    '${mainState.dropOffLocationName}',
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    'Choose a drop off location in map',
                                    overflow: TextOverflow.ellipsis,
                                  );
                          },
                        ),
                        trailing: IgnorePointer(
                          ignoring: true,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.arrow_forward_ios_rounded),
                            color: ColorService().grey,
                          ),
                        ),
                        onTap: () => {
                          SoundService.playClickSound(),
                          _navigateToDropOffLocationPicker(),
                        },
                      ),
                      _buildFindDriveButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildFindDriveButton() {
    return Consumer<MainState>(
      builder: (context, mainState, child) {
        return mainState.isPickUpLocationSet() &&
                mainState.isDropOffLocationSet()
            ? Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56.0,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                            backgroundColor: ColorService().green,
                            foregroundColor: ColorService().white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => {
                            SoundService.playOnlineSound(),
                            Navigator.pushNamed(
                              context,
                              '/driver_search_screen',
                            )
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text('NRs. 250'),
                              Text(
                                'Find a Driver',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0), // Space between buttons
                    // Reset Button
                    Expanded(
                      flex: 0,
                      child: SizedBox(
                        height: 56.0,
                        width: 56.0,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                            backgroundColor: ColorService().blackAccent,
                            foregroundColor: ColorService().grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => {
                            SoundService.playClickSound(),
                            mainState.resetDropOffLocation(),
                          },
                          child: Icon(
                            Icons.close,
                            color: ColorService().grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
