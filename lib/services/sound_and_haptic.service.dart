// import 'package:audioplayers/audioplayers.dart';
// import 'package:vibration/vibration.dart';

// class SoundAndHapticService {
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   // Singleton pattern to ensure only one instance of this service exists
//   static final SoundAndHapticService _instance =
//       SoundAndHapticService._internal();

//   factory SoundAndHapticService() {
//     return _instance;
//   }

//   SoundAndHapticService._internal();

//   // Single method to play sound and trigger haptic feedback
//   Future<void> playSoundAndHaptic({
//     String soundName = 'notification.mp3',
//     int vibrationDurationMs = 100,
//   }) async {
//     try {
//       // Play sound from assets
//       await _audioPlayer.play(AssetSource('sounds/$soundName'));
//     } catch (e) {
//       print('Error playing sound: $e');
//     }

//     // Trigger haptic feedback (vibration) if the device supports it
//     if (await Vibration.hasVibrator() ?? false) {
//       Vibration.vibrate(duration: vibrationDurationMs);
//     } else {
//       print('Haptic feedback not available on this device.');
//     }
//   }
// }
