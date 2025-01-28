import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ghodaa/screens/drop_off.driver.screen.dart';
import 'package:ghodaa/screens/drop_off.rider.screen.dart';
import 'package:ghodaa/screens/pick_up.driver.screen.dart';
import 'package:ghodaa/screens/pick_up.rider.screen.dart';
import 'package:ghodaa/screens/home.screen.dart';
import 'package:ghodaa/screens/search.rider.screen.dart';
import 'package:ghodaa/screens/landing.screen.dart';
import 'package:ghodaa/screens/map_location_picker.screen.dart';
import 'package:ghodaa/screens/search.driver.screen.dart';
import 'package:ghodaa/screens/splash.screen.dart';
import 'package:ghodaa/services/sound.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:provider/provider.dart';
import 'package:ghodaa/screens/driver_ride.screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> main() async {
  // Ensure the Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Error loading env: $e');
  }

  // Enable wakelock and handle potential errors
  try {
    await WakelockPlus.enable();
  } catch (e) {
    print('Error enabling wakelock: $e');
  }

  // initialize sounds
  await SoundService.init();

  // Run the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => MainState(), // Call initialization here
      child: MaterialApp(
        title: 'Ghodaa',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black54,
            elevation: 0,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.grey[400]),
          ),
          cardColor: Colors.grey[800],
          iconTheme: IconThemeData(color: Colors.white),
          buttonTheme: ButtonThemeData(buttonColor: Colors.blue),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/home_screen': (context) => const HomeScreen(),
          '/map_location_picker': (context) => const MapLocationPicker(),
          '/driver_search_screen': (context) => DriverSearchScreen(),
          '/rider_search_screen': (context) => RiderSearchScreen(),
          '/landing_screen': (context) => const LandingScreen(),
          '/new_ride_offer': (context) => const DriverRideScreen(),
          '/pick_up_rider_screen': (context) =>
              PickUpRiderScreen(rideId: '123'),
          '/pick_up_driver_screen': (context) =>
              PickUpDriverScreen(rideId: '123'),
          '/drop_off_rider_screen': (context) =>
              DropOffRiderScreen(rideId: '123'),
          '/drop_off_driver_screen': (context) =>
              DropOffDriverScreen(rideId: '123'),
        },
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (context) => const HomeScreen()),
      ),
    ),
  );
}
