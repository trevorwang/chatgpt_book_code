import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
        ref.watch(sessionWithMessageProvider).valueOrNull?.active ?? 0;
    final messages = ref.watch(messageProvider.select((value) =>
        value.where((element) => element.sessionId == activeSession).toList()));
    final listController = useScrollController();
    ref.listen(messageProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 50), () {
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
              return MessageItem(message: messages[index]);
            },
            itemCount: messages.length, // 消息数量
            separatorBuilder: (context, index) => const Divider(
              // 分割线
              height: 16,
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

class MessageItem extends StatelessWidget {
  final Message message;

  const MessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: message.isUser ? Colors.blue : Colors.blueGrey,
          child: message.isUser
              ? const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.android,
                  color: Colors.white,
                ),
        ),
        const SizedBox(
          width: 8,
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(right: 48),
            child: MessageContentWidget(
              message: message,
            ),
          ),
        ),
      ],
    );
  }
}
