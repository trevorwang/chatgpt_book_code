import 'dart:io';

import 'package:chatgpt/colors.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../injection.dart';
import '../models/session.dart';
import '../widgets/chat_message_list.dart';

class ExportService {
  Future<String?> exportMarkdown(
    Session session, {
    String? path,
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
    final file = File(path ?? "${dir.path}/${session.id}.md");
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String?> exportImage(
    Session session, {
    BuildContext? context,
    Size? targetSize,
    String? path,
  }) async {
    final controller = ScreenshotController();
    final messages = await db.messageDao.findMessagesBySessionId(session.id!);
    final key = GlobalKey();
    final widget = SingleChildScrollView(
      child: RepaintBoundary(
        key: key,
        child: Container(
          color: bgLight,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: messages
                .map((msg) => [
                      msg.isUser
                          ? SentMessageItem(
                              message: msg,
                              backgroundColor: sentMessageBgLight,
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
    final fileToSave = "${dir.path}/${session.id}.png";
    final file = File(path ?? fileToSave);
    file.writeAsBytes(img);
    return file.path;
  }
}
