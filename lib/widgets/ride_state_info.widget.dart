import 'package:flutter/material.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:ghodaa/widgets/ride_timeline.widget.dart';
import 'package:ghodaa/widgets/rider_info.widget.dart';
import 'package:provider/provider.dart';

class RideStateWidget extends StatelessWidget {
  const RideStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 400, // Set a minimum height for the widget
      ),
      child: Consumer<MainState>(
        builder: (context, mainState, child) {
          return Column(
            children: [
              CustomRiderInfo(
                profileImageUrl: mainState.customerProfilePictureURL, // Ensure a default value
                name: mainState.customerFullName ??
                    'Unknown Rider', // Provide a fallback
                description: mainState.customerDescription ??
                    'No description available', // Provide a fallback
              ),
              CustomRideTimeline(
                step: mainState.progressStep,
                userLatitude: mainState.customerLatitude ??
                    0.0, // Provide a default value
                userLongitude: mainState.customerLongitude ??
                    0.0, // Provide a default value
                pickUpLatitude:
                    mainState.pickUpLatitude ?? 0.0, // Provide a default value
                pickUpLongitude:
                    mainState.pickUpLongitude ?? 0.0, // Provide a default value
                dropOffLatitude:
                    mainState.dropOffLatitude ?? 0.0, // Provide a default value
                dropOffLongitude: mainState.dropOffLongitude ??
                    0.0, // Provide a default value
              ),
            ],
          );
        },
      ),
    );
  }
}
