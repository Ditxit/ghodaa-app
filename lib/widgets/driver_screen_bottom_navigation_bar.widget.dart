import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ghodaa/screens/celebration.screen.dart';
import 'package:ghodaa/screens/qr_scanner.screen.dart';
import 'package:provider/provider.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:ghodaa/widgets/text.widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverScreenBottomNavigationBar extends StatelessWidget {
  const DriverScreenBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context);

    String firstButtonText;
    Icon firstButtonIcon;
    VoidCallback? firstButtonAction;
    VoidCallback? secondButtonAction;

    switch (mainState.progressStep) {
      case 0:
        firstButtonText = "Unknown Action";
        firstButtonIcon = const Icon(Icons.help, color: Colors.white);
        firstButtonAction = () {};
        break;

      case 1:
        firstButtonText = "Accept Offer";
        firstButtonIcon = const Icon(Icons.check, color: Colors.white);
        firstButtonAction = () => mainState.advanceProgressStep();
        break;

      case 2:
        firstButtonText = isNear(
                mainState.customerLatitude ?? 0.0,
                mainState.customerLongitude ?? 0.0,
                mainState.pickUpLatitude ?? 0.0,
                mainState.pickUpLongitude ?? 0.0)
            ? "Start Ride"
            : "Navigate to Pickup";
        firstButtonIcon = const Icon(Icons.route, color: Colors.white);
        firstButtonAction = () {
          _openMap(
            mainState.pickUpLatitude ?? 0.0,
            mainState.pickUpLongitude ?? 0.0,
            context,
          );
        };
        // secondButtonAction = () => Navigator.of(context).push(
        //       MaterialPageRoute(builder: (context) => const QRScanPage()),
        //     ); // Navigate to QRScanPage
        break;

      case 3:
        firstButtonText = "Drop Off Rider";
        firstButtonIcon = const Icon(Icons.route, color: Colors.white);
        firstButtonAction = () {
          _openMap(
            mainState.dropOffLatitude ?? 0.0,
            mainState.dropOffLongitude ?? 0.0,
            context,
          );
        };
        // secondButtonAction = () {
        //   Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => const QRScanPage()),
        //   ); // Navigate to QRScanPage
        // }; // QR Action
        break;

      case 4:
        firstButtonText = "Complete Ride";
        firstButtonIcon = const Icon(Icons.check_circle, color: Colors.white);
        firstButtonAction = () {
          mainState.updateProgressStep(0); // Reset progress step
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CelebrationScreen()),
          );
        };
        break;

      default:
        firstButtonText = "Unknown Action";
        firstButtonIcon = const Icon(Icons.help, color: Colors.white);
        firstButtonAction = () {};
        break;
    }

    return _buildButtonLayout(firstButtonText, firstButtonIcon,
        firstButtonAction, secondButtonAction);
  }

  bool isNear(
      double userLat, double userLon, double targetLat, double targetLon,
      {double threshold = 0.01}) {
    return (userLat - targetLat).abs() < threshold &&
        (userLon - targetLon).abs() < threshold;
  }

  Future<bool> _openMap(
      double latitude, double longitude, BuildContext context) async {
    final Uri url = Platform.isIOS
        ? Uri.parse(
            'maps:0,0?q=$latitude,$longitude') // Use maps scheme for iOS
        : Uri.parse('geo:$latitude,$longitude'); // Use geo scheme for Android

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return true;
    } else {
      _showErrorMessage(context);
      return false;
    }
  }

  void _showErrorMessage(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Expanded(
            child: Text(
              'Could not open the map. Install a maps app!',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              const appStoreUrl =
                  'https://apps.apple.com/us/app/apple-maps/id915056600'; // iOS App Store URL
              const playStoreUrl =
                  'https://play.google.com/store/apps/details?id=com.google.android.apps.maps'; // Android Play Store URL
              final url = Platform.isIOS ? appStoreUrl : playStoreUrl;

              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
            child:
                const Text('Find Map', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildButtonLayout(String firstButtonText, Icon firstButtonIcon,
      VoidCallback? firstButtonAction, VoidCallback? secondButtonAction) {
    return Container(
      color: Colors.deepPurple,
      height: 88,
      child: Row(
        mainAxisAlignment: secondButtonAction != null
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        children: <Widget>[
          _buildAnimatedTextButton(
              firstButtonText, firstButtonIcon, firstButtonAction),
          if (secondButtonAction != null)
            _buildSquareIconButton(secondButtonAction),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextButton(
      String text, Icon icon, VoidCallback? onPressed) {
    return Expanded(
      child: SizedBox(
        height: 88,
        child: Tooltip(
          message: "Tap to navigate",
          child: TextButton(
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                CustomText(text: text, fontColor: Colors.white, fontSize: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareIconButton(VoidCallback? onPressed) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Tooltip(
        message: "Scan QR Code",
        child: Container(
          color: Colors.deepPurple[800],
          child: TextButton(
            onPressed: onPressed,
            child: const Icon(Icons.qr_code_scanner,
                color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
