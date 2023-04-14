import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../states/chat_ui_state.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';

class UserInputWidget extends HookConsumerWidget {
  const UserInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUIState = ref.watch(chatUiProvider);
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    return TextField(
      // minLines: 1,
      // maxLines: 3,
      controller: controller,
      focusNode: focusNode,

      autofocus: true,
      onSubmitted: (value) {
        if (chatUIState.requestLoading) return;
        if (value.isNotEmpty) {
          _sendMessage(ref, controller, focusNode: focusNode);
        }
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: 'Send a message...', // 显示在输入框内的提示文字
          suffixIcon: chatUIState.requestLoading
              ? const SizedBox(
                  width: 40,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    // 这里处理发送事件
                    if (controller.text.isNotEmpty) {
                      _sendMessage(ref, controller, focusNode: focusNode);
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

  _requestChatGPT(WidgetRef ref, List<Message> messages, int sessionId) async {
    ref.read(chatUiProvider.notifier).setRequestLoading(true);
    try {
      final id = uuid.v4();
      await chatgpt.streamChat(
        messages: messages,
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
  _sendMessage(
    WidgetRef ref,
    TextEditingController controller, {
    FocusNode? focusNode,
  }) async {
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

    focusNode?.requestFocus();
    final messageToSubmit = ref.watch(messageProvider.select((value) =>
        value.where((element) => element.sessionId == sessionId).toList()));

    final tokens = messageToSubmit.map((e) => e.content).join('\n');
    while (tokens.length > 3000) {
      messageToSubmit.removeAt(0);
    }
    _requestChatGPT(ref, messageToSubmit, sessionId);
  }
}
