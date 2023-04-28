import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown/code_wrapper.dart';
import '../models/session.dart';
import '../states/message_state.dart';
import '../injection.dart';
import '../markdown/latex.dart';
import '../models/message.dart';
import '../states/chat_ui_state.dart';
import '../states/session_state.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              GoRouter.of(context).push('/history');
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () {
              ref
                  .read(sessionStateNotifierProvider.notifier)
                  .setActiveSession(null);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: const [
            Expanded(
              // 聊天消息列表
              child: ChatMessageList(),
            ),
            // 输入框
            UserInputWidget(),
          ],
        ),
      ),
    );
  }
}

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

class UserInputWidget extends HookConsumerWidget {
  const UserInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUIState = ref.watch(chatUiProvider);
    final controller = useTextEditingController();
    return TextField(
      enabled: !chatUIState.requestLoading,
      controller: controller,
      decoration: InputDecoration(
          hintText: 'Type a message', // 显示在输入框内的提示文字
          suffixIcon: IconButton(
            onPressed: () {
              // 这里处理发送事件
              if (controller.text.isNotEmpty) {
                _sendMessage(ref, controller);
              }
            },
            icon: const Icon(
              Icons.send,
            ),
          )),
    );
  }

  // 增加WidgetRef
  _sendMessage(WidgetRef ref, TextEditingController controller) async {
    final content = controller.text;
    Message message = _createMessage(content);

    var active = ref.watch(activeSessionProvider);
    var sessionId = active?.id ?? 0;
    if (sessionId <= 0) {
      active = Session(title: content);
      // final id = await db.sessionDao.upsertSession(active);
      active = await ref
          .read(sessionStateNotifierProvider.notifier)
          .insertSession(active);
      sessionId = active.id!;
      ref
          .read(sessionStateNotifierProvider.notifier)
          .setActiveSession(active.copyWith(id: sessionId));
    }

    ref.read(messageProvider.notifier).upsertMessage(
          message.copyWith(sessionId: sessionId),
        ); // 添加消息
    controller.clear();
    _requestChatGPT(ref, content, sessionId: sessionId);
  }

  Message _createMessage(
    String content, {
    String? id,
    bool isUser = true,
    int? sessionId,
  }) {
    final message = Message(
      id: id ?? uuid.v4(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
      sessionId: sessionId ?? 0,
    );
    return message;
  }

  _requestChatGPT(
    WidgetRef ref,
    String content, {
    int? sessionId,
  }) async {
    ref.read(chatUiProvider.notifier).setRequestLoading(true);
    try {
      final id = uuid.v4();
      await chatgpt.streamChat(
        content,
        onSuccess: (text) {
          final message =
              _createMessage(text, id: id, isUser: false, sessionId: sessionId);
          ref.read(messageProvider.notifier).upsertMessage(message);
        },
      );
    } catch (err) {
      logger.e("requestChatGPT error: $err", err);
    } finally {
      ref.read(chatUiProvider.notifier).setRequestLoading(false);
    }
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
