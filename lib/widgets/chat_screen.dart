import 'package:chatgpt/injection.dart';
import 'package:chatgpt/markdown/latex.dart';
import 'package:chatgpt/models/message.dart';
import 'package:chatgpt/states/chat_ui_state.dart';
import 'package:chatgpt/states/session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown/code_wrapper.dart';
import '../models/session.dart';
import '../states/message_state.dart';

class ChatHistoryList extends HookConsumerWidget {
  const ChatHistoryList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionWithMessageProvider);
    return sessionState.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        data: (data) {
          return ListView(
            children: [
              ListTile(
                title: ElevatedButton(
                  onPressed: () {
                    ref.read(sessionWithMessageProvider.notifier).active(null);
                  },
                  child: const Text("New Chat"),
                ),
              ),
              for (var session in data.sessions)
                ListTile(
                  title: Text(session.title),
                  selected: data.active == session.id,
                  onTap: () {
                    ref
                        .read(sessionWithMessageProvider.notifier)
                        .active(session.id);
                  },
                ),
            ],
          );
        },
        error: (err, stack) => Text("$err - $stack"),
        loading: () {
          return const CircularProgressIndicator();
        });
  }
}

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

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const SizedBox(
              width: 200,
              child: ChatHistoryList(),
            ),
            Expanded(
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
            )
          ],
        ),
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

  Message _createMessage(
    String id,
    String text, {
    bool isUser = false,
    int? sessionId,
  }) {
    final message = Message(
      id: id,
      content: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      sessionId: sessionId ?? 0,
    );
    return message;
  }

  _requestChatGPT(WidgetRef ref, String content, int sessionId) async {
    ref.read(chatUiProvider.notifier).setRequestLoading(true);
    try {
      final id = uuid.v4();
      await chatgpt.streamChat(
        content,
        onSuccess: (text) {
          final msg = _createMessage(
            id,
            text,
            sessionId: sessionId,
          );
          ref.read(messageProvider.notifier).upsertMessage(msg);
        },
      );
    } catch (err) {
      logger.e("requestChatGPT error: $err", err);
    } finally {
      ref.read(chatUiProvider.notifier).setRequestLoading(false);
    }
  }

  // 增加WidgetRef
  _sendMessage(WidgetRef ref, TextEditingController controller) async {
    final content = controller.text;
    var sessionId =
        ref.watch(sessionWithMessageProvider).valueOrNull?.active ?? 0;

    if (sessionId <= 0) {
      final session = await ref
          .read(sessionWithMessageProvider.notifier)
          .insertSession(Session(title: content));
      sessionId = session.id!;
    }
    final msg =
        _createMessage(uuid.v4(), content, isUser: true, sessionId: sessionId);
    ref.read(messageProvider.notifier).upsertMessage(msg);
    controller.clear();
    _requestChatGPT(ref, content, sessionId);
  }
}
