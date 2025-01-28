import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ghodaa/services/sound.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:provider/provider.dart';

String generateRandomString(int length) {
  // const characters =
  //     'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  const characters = '0123456789';
  Random random = Random();

  return List.generate(length, (index) {
    return characters[random.nextInt(characters.length)];
  }).join();
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = 'U${generateRandomString(4)}';
  }

  @override
  void dispose() {
    // Dispose the TextEditingController to free up resources
    _nameController.dispose();
    super.dispose();
  }

  void _becomeDriver(BuildContext context, MainState mainState) {
    String name = _nameController.text;
    mainState.setUserId(name);
    mainState.setUserToken('{"id": "$name", "type": "driver"}');
    mainState.setUserType('driver');
    mainState.setUserFullName(name);
    // mainState.setCurrentRoute('/home_screen', {});
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home_screen',
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  void _becomeRider(BuildContext context, MainState mainState) {
    String name = _nameController.text;
    mainState.setUserId(name);
    mainState.setUserToken('{"id": "$name", "type": "rider"}');
    mainState.setUserType('rider');
    mainState.setUserFullName(name);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home_screen',
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 60,
              width: 300,
              child: ElevatedButton(
                onPressed: () => {
                  SoundService.playClickSound(),
                  _becomeDriver(context, mainState),
                },
                child: Text(
                  'Be Driver',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 60,
              width: 300,
              child: ElevatedButton(
                onPressed: () => {
                  SoundService.playClickSound(),
                  _becomeRider(context, mainState),
                },
                child: Text(
                  'Be Rider',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
