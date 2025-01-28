import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // sound file path
  static final String _clickSound = 'sounds/click.mp3';
  static final String _matchSound = 'sounds/match.mp3';

  static final String _onlineSound = 'sounds/online.mp3';
  static final String _offlineSound = 'sounds/offline.mp3';

  // init method, usually initilize this in main() method
  static Future<void> init() async {
    await _audioPlayer.setSourceAsset(_clickSound);
    await _audioPlayer.setSourceAsset(_matchSound);
    await _audioPlayer.setSourceAsset(_onlineSound);
    await _audioPlayer.setSourceAsset(_offlineSound);
  }

  static Future<void> playClickSound() async {
    await _audioPlayer.play(AssetSource(_clickSound));
  }

  static Future<void> playMatchSound() async {
    await _audioPlayer.play(AssetSource(_matchSound));
  }

  static Future<void> playOnlineSound() async {
    await _audioPlayer.play(AssetSource(_onlineSound));
  }

  static Future<void> playOfflineSound() async {
    await _audioPlayer.play(AssetSource(_offlineSound));
  }
}
