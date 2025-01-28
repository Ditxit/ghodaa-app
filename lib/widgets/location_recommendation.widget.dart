import 'package:flutter/material.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:ghodaa/widgets/ghost.widget.dart';
import 'package:provider/provider.dart';

class Location {
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final bool isCurrentLocation;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description = '',
    this.isCurrentLocation = false,
  });
}

class LocationRecommendation extends StatelessWidget {
  LocationRecommendation({super.key});

  // Static location data near Fremont and Mowry
  final List<Location> locations = [
    Location(
      name: 'Current Location',
      latitude: 0.0,
      longitude: 0.0,
      description: 'Your current location.',
      isCurrentLocation: true,
    ),
    Location(
      name: 'Central Park',
      latitude: 37.5485,
      longitude: -121.9886,
      description:
          'A spacious park with walking trails, a lake, and sports facilities.',
    ),
    Location(
      name: 'Lake Elizabeth',
      latitude: 37.5482,
      longitude: -121.9864,
      description: 'A scenic lake perfect for picnics and leisurely walks.',
    ),
    Location(
      name: 'Mission Peak Regional Preserve',
      latitude: 37.5603,
      longitude: -121.8880,
      description:
          'Famous for its hiking trails and stunning views of the Bay Area.',
    ),
    Location(
      name: 'Coyote Hills Regional Park',
      latitude: 37.5180,
      longitude: -122.0505,
      description: 'Great for trails, wetlands, and beautiful bay views.',
    ),
    Location(
      name: 'Fremont Art Association',
      latitude: 37.5487,
      longitude: -121.9892,
      description: 'A local art gallery showcasing community art and events.',
    ),
    Location(
      name: 'Shinn Historical Park and Arboretum',
      latitude: 37.5562,
      longitude: -121.9834,
      description: 'A historical site with lovely gardens and walking paths.',
    ),
    Location(
      name: 'Don Edwards San Francisco Bay National Wildlife Refuge',
      latitude: 37.4946,
      longitude: -122.0220,
      description: 'Perfect for bird watching and enjoying nature.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MainState>(
      builder: (context, mainState, child) {
        if (!mainState.isRecommendationVisible()) {
          return const CustomGhostWidget();
        }

        // int itemCount = locations.length > 5 ? 5 : locations.length;
        // double height = itemCount * 72.0;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: ListView.separated(
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      size: 28.0,
                      location.isCurrentLocation
                          ? Icons.my_location
                          : Icons.location_on,
                      color: mainState.isPickUpLocationSet()
                          ? ColorService().red
                          : ColorService().green,
                    ),
                  ),
                  title: Text(
                    location.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorService().white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    location.description,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorService().grey,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    // Update the pick-up location in MainState
                    if (mainState.isPickUpLocationSet()) {
                      mainState.setDropOffLocation(
                        'drop off location name',
                        location.isCurrentLocation
                            ? mainState.customerLatitude!
                            : location.latitude,
                        location.isCurrentLocation
                            ? mainState.customerLongitude!
                            : location.longitude,
                      );
                    } else {
                      mainState.setPickUpLocation(
                        'pick up location name',
                        location.isCurrentLocation
                            ? mainState.customerLatitude!
                            : location.latitude,
                        location.isCurrentLocation
                            ? mainState.customerLongitude!
                            : location.longitude,
                      );
                    }
                    mainState.setRecommendationVisibility(false);

                    // Optionally show feedback
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('Location Set up: ${location.name}')),
                    // );
                  });
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                color: ColorService().blackAccent,
              );
            },
            itemCount: locations.length,
          ),
        );
      },
    );
  }
}
