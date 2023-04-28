import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown/code_wrapper.dart';
import '../markdown/latex.dart';
import '../models/message.dart';
import '../states/message_state.dart';

class ChatMessageList extends HookConsumerWidget {
  const ChatMessageList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(activeSessionMessagesProvider);
    final listController = useScrollController();
    ref.listen(activeSessionMessagesProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 50), () {
        listController.jumpTo(
          listController.position.maxScrollExtent,
        );
      });
    });
    return ListView.separated(
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

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.message,
  });

  final Message message;

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

class MessageContentWidget extends StatelessWidget {
  const MessageContentWidget({
    super.key,
    required this.message,
  });

  final Message message;

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
