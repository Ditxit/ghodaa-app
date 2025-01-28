import 'package:flutter/material.dart';

class NavigatorService {
  static void navigate(
    BuildContext context,
    String route, {
    Map<String, String>? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (Route<dynamic> route) => false, // Remove all previous routes
      arguments: arguments, // If any, can be null
    );
  }

  static void navigateIfScreenNeedToChange(
    BuildContext context,
    List<String> currentScreens, // Now accepts a list of screens
    String nextScreen,
  ) {
    if (currentScreens.contains(nextScreen)) return;

    String route;
    switch (nextScreen) {
      case 'RIDER_HOME_SCREEN':
        route = '/home_screen';
        break;
      case 'DRIVER_HOME_SCREEN':
        route = '/home_screen';
        break;
      case 'PAYMENT_SCREEN':
        route = '/home_screen';
        break;
      case 'RIDER_DROP_OFF_SCREEN':
        route = '/drop_off_rider_screen';
        break;
      case 'DRIVER_DROP_OFF_SCREEN':
        route = '/drop_off_driver_screen';
        break;
      case 'RIDER_PICK_UP_SCREEN':
        route = '/pick_up_rider_screen';
        break;
      case 'DRIVER_PICK_UP_SCREEN':
        route = '/pick_up_driver_screen';
        break;
      default:
        route = '/home_screen';
        break;
    }

    NavigatorService.navigate(context, route, arguments: {});
  }
}
