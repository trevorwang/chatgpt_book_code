import 'dart:async';

import 'package:file_picker/file_picker.dart';

Future<String?> saveAs({
  String? fileName,
}) async {
  return await FilePicker.platform.saveFile(
    dialogTitle: 'Save as...',
    fileName: fileName ?? 'untitled',
  );
}
