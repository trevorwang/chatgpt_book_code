import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../injection.dart';

class RecordingSeorvice {
  final r = Record();

  record({String? fileName}) async {
    if (await r.hasPermission()) {
      final path = await getTemporaryDirectory();

      final d = Directory("${path.absolute.path}/audios/");
      await d.create(recursive: true);

      final file =
          File("${d.path}/${DateTime.now().microsecondsSinceEpoch}.m4a");
      logger.d('path: ${file.path}');

      await r.start(
        path: Uri.file(file.path).toString(),
      );
    }
  }

  Future<String?> stop() async {
    return await r.stop();
  }

  Future<bool> isRecording() async {
    return await r.isRecording();
  }
}
