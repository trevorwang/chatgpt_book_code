import 'dart:io';

import '../injection.dart';
import '../models/session.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  void exportMarkdown(
    Session session, {
    String? fileName,
  }) async {
    final messages = await db.messageDao.findMessagesBySessionId(session.id!);
    final buffer = StringBuffer();
    for (var element in messages) {
      var content = element.content;
      if (element.isUser) {
        content = "> $content";
      }
      buffer.writeln();
      buffer.writeln(content);
    }
    logger.v(buffer.toString());
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory("${docDir.path}/exports/markdown");
    await dir.create(recursive: true);
    final file = File("${dir.path}/${fileName ?? session.id}.md");
    await file.writeAsString(buffer.toString());
  }
}
