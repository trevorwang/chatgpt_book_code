import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  AudioPlayerService._();
  static final instance = AudioPlayerService._();
  final audioPlayer = AudioPlayer()
    ..setReleaseMode(
      ReleaseMode.stop,
    );

  Future<void> play(List<int> audio) async {
    await audioPlayer.play(BytesSource(Uint8List.fromList(audio)));
  }

  Future<void> play2(File file) async {
    await audioPlayer.play(DeviceFileSource(file.absolute.path));
  }
}
