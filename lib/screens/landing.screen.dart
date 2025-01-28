import 'package:flutter/material.dart';
import 'package:ghodaa/widgets/customer_appbar.widget.dart';
import 'package:ghodaa/widgets/customer_ride_summary.widget.dart';
import 'package:ghodaa/widgets/google_map.widget.dart';
import 'package:ghodaa/widgets/location_recommendation.widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: const FindRideAppBar(),
      appBar: CustomerAppBar(),
      body: Stack(
        children: [
          const NavigationMapWidget(), // Google Map widget
          const CustomerRideSummary(),
          LocationRecommendation(),
          // const FindRide(),
        ],
      ),
    );
  }
}
