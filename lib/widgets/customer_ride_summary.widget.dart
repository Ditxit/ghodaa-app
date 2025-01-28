import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/services/estimated_fare_calculator.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:ghodaa/widgets/ghost.widget.dart';
import 'package:ghodaa/widgets/static_map.widget.dart';
import 'package:ghodaa/widgets/text.widgets.dart';
import 'package:provider/provider.dart';

final fareCalculator = EstimatedFareCalculatorService();

class CustomerRideSummary extends StatelessWidget {
  const CustomerRideSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.sizeOf(context).height;

    return Consumer<MainState>(
      builder: (context, mainState, child) {
        if (!mainState.isDropOffLocationSet()) {
          return const CustomGhostWidget();
        }

        return Container(
          color: ColorService().black,
          child: ListView(
            // mainAxis: Axis.vertical,
            children: [
              StaticMapWidget(
                height: 300,
                width: screenWidth,
                locations: [
                  {
                    'latitude': mainState.pickUpLatitude,
                    'longitude': mainState.pickUpLongitude,
                    'name': "Pick Up",
                    'color': ColorService().green,
                    'icon': Icons.place, // Icon for the current location
                  },
                  {
                    'latitude': mainState.dropOffLatitude,
                    'longitude': mainState.dropOffLongitude,
                    'name': "Drop Off",
                    'color': ColorService().red,
                    'icon': Icons.place, // Icon for the current location
                  },
                ],
              ),
              _customTile(
                icon: Icons.currency_rupee,
                iconColor: ColorService().grey,
                title: 'NRs. ${_getEstimatedFare(mainState).toString()}',
                titleColor: ColorService().white,
                subtitle: 'Estimated Fair',
                subtitleColor: ColorService().grey,
              ),
              _customTile(
                icon: Icons.route,
                iconColor: ColorService().grey,
                title: _getEstimatedDistance(mainState).toString(),
                titleColor: Colors.white,
                subtitle: 'Travel Distance',
                subtitleColor: ColorService().grey,
              ),
              _customTile(
                icon: Icons.place,
                iconColor: ColorService().green,
                title:
                    '${mainState.pickUpLatitude}, ${mainState.pickUpLongitude} fsjkal;ksfjsal;kfjsalkjflksajflkjasflkjas;lkfjaslkjfalskjfl;kasjlkafjslkjfsalkfs',
                titleColor: Colors.white,
                subtitle: 'Pick Up Location',
                subtitleColor: ColorService().grey,
              ),
              _customTile(
                icon: Icons.place,
                iconColor: ColorService().red,
                title:
                    '${mainState.dropOffLatitude}, ${mainState.dropOffLongitude} fsjkal;ksfjsal;kfjsalkjflksajflkjasflkjas;lkfjaslkjfalskjfl;kasjlkafjslkjfsalkfs',
                titleColor: Colors.white,
                subtitle: 'Drop Off Location',
                subtitleColor: ColorService().grey,
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 64, // <-- Your height
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: ColorService().green,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(10, 10)),
                      ),
                    ),
                    onPressed: () => {
                      SystemSound.play(SystemSoundType.click),
                    },
                    child: CustomText(
                      text: 'Search Rides',
                      fontColor: ColorService().white,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _getEstimatedDistance(MainState mainState) {
  try {
    final km = fareCalculator.calculateDistance(
      mainState.pickUpLatitude!,
      mainState.pickUpLongitude!,
      mainState.dropOffLatitude!,
      mainState.dropOffLongitude!,
    );

    return '${km.toStringAsFixed(2)} km';
  } catch (error) {
    print(error);
    return '0 Km';
  }
}

int _getEstimatedFare(MainState mainState) {
  try {
    final locations = [
      {'lat': mainState.pickUpLatitude!, 'lng': mainState.pickUpLongitude!},
      {'lat': mainState.dropOffLatitude!, 'lng': mainState.dropOffLongitude!},
    ];
    return fareCalculator.estimateFare(
      locations: locations,
      farePerKm: 2.0,
      breakpointKm: 5.0,
      inflationMultiplierOnBreakpoint: 1.5,
    );
  } catch (error) {
    print(error);
    return 0;
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
        : CustomGhostWidget(),
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
