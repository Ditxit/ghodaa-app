import 'package:flutter/material.dart';
import 'package:ghodaa/services/location.service.dart';
// import 'package:ghodaa/widgets/ghost.widget.dart';
// import 'package:ghodaa/widgets/text.widgets.dart';
// import 'package:timelines/timelines.dart';

class CustomRideTimeline extends StatelessWidget {
  final int step;
  final double userLatitude;
  final double userLongitude;
  final double pickUpLatitude;
  final double pickUpLongitude;
  final double dropOffLatitude;
  final double dropOffLongitude;

  const CustomRideTimeline({
    super.key,
    required this.step,
    required this.userLatitude,
    required this.userLongitude,
    required this.pickUpLatitude,
    required this.pickUpLongitude,
    required this.dropOffLatitude,
    required this.dropOffLongitude,
  });

  @override
  Widget build(BuildContext context) {
    // Create an instance of LocationService
    final locationService = LocationService();

    // Calculate distances and estimated times for pick-up and drop-off
    final String pickUpDistanceAndTimeText = locationService.calculateDistanceAndTime(
      userLatitude,
      userLongitude,
      pickUpLatitude,
      pickUpLongitude,
      25,
    );

    final String dropOffDistanceAndTimeText = locationService.calculateDistanceAndTime(
      pickUpLatitude,
      pickUpLongitude,
      dropOffLatitude,
      dropOffLongitude,
      25,
    );

    return Container();

    // return FixedTimeline(
    //   theme: TimelineThemeData(
    //     color: Colors.white,
    //   ),
    //   children: [
    //     // Timeline tile for accepting offer
    //     TimelineTile(
    //       oppositeContents: const Padding(
    //         padding: EdgeInsets.all(12.0),
    //         child: CustomText(
    //           text: 'Accept Offer',
    //           fontColor: Colors.white,
    //         ),
    //       ),
    //       node: TimelineNode(
    //         indicator: DotIndicator(
    //           size: 32,
    //           color: step >= 1 ? Colors.deepPurple : Colors.deepOrange,
    //           child: switch (step) {
    //             0 => const CustomGhostWidget(),
    //             1 => const Icon(Icons.lens_blur, color: Colors.white),
    //             2 => const Icon(Icons.check, color: Colors.white),
    //             3 => const Icon(Icons.check, color: Colors.white),
    //             4 => const Icon(Icons.check, color: Colors.white),
    //             _ => const Icon(Icons.question_mark, color: Colors.red),
    //           },
    //         ),
    //         endConnector: const SizedBox(
    //           height: 40,
    //           child: SolidLineConnector(
    //             thickness: 4,
    //             color: Colors.white70,
    //           ),
    //         ),
    //       ),
    //     ),
    //     // Timeline tile for pick-up distance and time
    //     TimelineTile(
    //       node: TimelineNode(
    //         indicator: Card(
    //           color: Colors.white70,
    //           margin: EdgeInsets.zero,
    //           child: Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: CustomText(text: pickUpDistanceAndTimeText),
    //           ),
    //         ),
    //         endConnector: const SizedBox(
    //           height: 0,
    //           child: SolidLineConnector(
    //             thickness: 4,
    //             color: Colors.white70,
    //           ),
    //         ),
    //       ),
    //     ),
    //     // Timeline tile for picking up the rider
    //     TimelineTile(
    //       contents: const Padding(
    //         padding: EdgeInsets.all(12.0),
    //         child: CustomText(
    //           text: 'Pickup Rider',
    //           fontColor: Colors.white,
    //         ),
    //       ),
    //       node: TimelineNode(
    //         indicator: DotIndicator(
    //           size: 32,
    //           color: step >= 2 ? Colors.deepPurple : Colors.deepOrange,
    //           child: switch (step) {
    //             0 => const CustomGhostWidget(),
    //             1 => const CustomGhostWidget(),
    //             2 => const Icon(Icons.lens_blur, color: Colors.white),
    //             3 => const Icon(Icons.check, color: Colors.white),
    //             4 => const Icon(Icons.check, color: Colors.white),
    //             _ => const Icon(Icons.question_mark, color: Colors.red),
    //           },
    //         ),
    //         startConnector: const SizedBox(
    //           height: 40,
    //           child: SolidLineConnector(
    //             thickness: 4,
    //             color: Colors.white70,
    //           ),
    //         ),
    //         endConnector: const SizedBox(
    //           height: 40,
    //           child: SolidLineConnector(
    //             thickness: 4,
    //             color: Colors.white70,
    //           ),
    //         ),
    //       ),
    //     ),
    //     // Timeline tile for drop-off distance and time
    //     TimelineTile(
    //       node: TimelineNode(
    //         indicator: Card(
    //           color: Colors.white70,
    //           margin: EdgeInsets.zero,
    //           child: Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: CustomText(text: dropOffDistanceAndTimeText),
    //           ),
    //         ),
    //         endConnector: const SizedBox(
    //           height: 0,
    //           child: SolidLineConnector(
    //             thickness: 4,
    //             color: Colors.white70,
    //           ),
    //         ),
    //       ),
    //     ),
    //     // Timeline tile for dropping off the rider
    //     TimelineTile(
    //       oppositeContents: const Padding(
    //         padding: EdgeInsets.all(12.0),
    //         child: CustomText(
    //           text: 'Drop Rider',
    //           fontColor: Colors.white,
    //         ),
    //       ),
    //       node: TimelineNode(
    //         indicator: DotIndicator(
    //           size: 32,
    //           color: step >= 3 ? Colors.deepPurple : Colors.deepOrange,
    //           child: switch (step) {
    //             0 => const CustomGhostWidget(),
    //             1 => const CustomGhostWidget(),
    //             2 => const CustomGhostWidget(),
    //             3 => const Icon(Icons.lens_blur, color: Colors.white),
    //             4 => const Icon(Icons.check, color: Colors.white),
    //             _ => const Icon(Icons.question_mark, color: Colors.red),
    //           },
    //         ),
    //         startConnector: const SizedBox(
    //           height: 40,
    //           child: SolidLineConnector(
    //             thickness: 4,
    //             color: Colors.white70,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
