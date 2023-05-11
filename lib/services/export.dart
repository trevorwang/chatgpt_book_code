import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../injection.dart';
import '../models/session.dart';
import '../widgets/chat_message_list.dart';

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

  void exportImage(
    Session session, {
    BuildContext? context,
    Size? targetSize,
  }) async {
    final controller = ScreenshotController();
    final messages = await db.messageDao.findMessagesBySessionId(session.id!);
    final key = GlobalKey();
    final widget = SingleChildScrollView(
      child: RepaintBoundary(
        key: key,
        child: Container(
          color: const Color(0xFFF1F1F1),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: messages
                .map((msg) => [
                      msg.isUser
                          ? SentMessageItem(
                              message: msg,
                              backgroundColor: const Color(0xFF8FE869),
                            )
                          : ReceivedMessageItem(
                              message: msg,
                            ),
                      const Divider(
                        color: Colors.transparent,
                        height: 16,
                      )
                    ])
                .expand((element) => element)
                .toList(),
          ),
        ),
      ),
    );
    // ignore: use_build_context_synchronously
    final img = await controller.captureFromWidget(
      widget,
      context: context,
      targetSize: targetSize,
    );
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory("${docDir.path}/exports/img");
    await dir.create(recursive: true);
    final file = File("${dir.path}/${session.id}.png");
    file.writeAsBytes(img);
  }
}
