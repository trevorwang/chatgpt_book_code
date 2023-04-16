import 'package:chatgpt/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown/code_wrapper.dart';
import '../markdown/latex.dart';
import '../models/message.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';

class ChatMessageList extends HookConsumerWidget {
  const ChatMessageList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession =
        ref.watch(sessionWithMessageProvider).valueOrNull?.active;
    final messages = ref.watch(messageProvider.select((value) => value
        .where((element) => element.sessionId == activeSession?.id)
        .toList()));
    final listController = useScrollController();
    ref.listen(messageProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!listController.hasClients) return;
        listController.jumpTo(
          listController.position.maxScrollExtent,
        );
      });
    });
    return messages.isEmpty
        ? const Center(
            child: Text(
              "ChatGPT",
              style: TextStyle(
                fontSize: 36,
                color: Colors.grey,
              ),
            ),
          )
        : ListView.separated(
            controller: listController,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return msg.isUser
                  ? SentMessageItem(message: msg)
                  : ReceivedMessageItem(message: msg);
            },
            itemCount: messages.length, // 消息数量
            separatorBuilder: (context, index) => const Divider(
              // 分割线
              height: 16,
              color: Colors.transparent,
            ),
          );
  }
}

class MessageContentWidget extends StatelessWidget {
  final Message message;

  const MessageContentWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    codeWrapper(child, text) => CodeWrapperWidget(child: child, text: text);
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: MarkdownGenerator(
          config: MarkdownConfig().copy(configs: [
            const PreConfig().copy(wrapper: codeWrapper),
          ]),
          generators: [
            latexGenerator,
          ],
          inlineSyntaxes: [
            LatexSyntax(),
          ],
        ).buildWidgets(message.content),
      ),
    );
  }
}

class SentMessageItem extends StatelessWidget {
  final Message message;

  const SentMessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isDesktop() ? 80 : 40,
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: MessageContentWidget(message: message),
          ),
        ),
        SizedBox(
            width: 10, child: CustomPaint(painter: CustomShape(Colors.white))),
        const CircleAvatar(
          radius: 20,
          child: Text("A"),
        ),
      ],
    );
  }
}

class ReceivedMessageItem extends StatelessWidget {
  final Message message;

  const ReceivedMessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: SvgPicture.asset(
            "assets/images/chatgpt.svg",
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        CustomPaint(painter: CustomShape(Colors.white)),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: MessageContentWidget(message: message),
          ),
        ),
        SizedBox(
          width: isDesktop() ? 80 : 40,
        ),
      ],
    );
  }
}

class CustomShape extends CustomPainter {
  final Color bgColor;

  CustomShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
