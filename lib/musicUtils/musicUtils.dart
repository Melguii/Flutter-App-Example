import 'package:audioplayers/audio_cache.dart';

class musicUtils {
  static musicUtils _instance;
  static AudioCache player;
  final pinguSound = "noot_noot.mp3";

  musicUtils._internal() {
    player = new AudioCache();
  }

  static musicUtils getState() {
    if (_instance == null) {
      _instance = musicUtils._internal();
    }
    return _instance;
  }

  playMusic() {
    player.play(pinguSound);
  }
}