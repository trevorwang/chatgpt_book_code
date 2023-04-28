import 'package:chatgpt/widgets/chat_gpt_model_widget.dart';
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
    final controller = useTextEditingController();
    final uiState = ref.watch(chatUiProvider);
    return TextField(
      enabled: !uiState.requestLoading,
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
    final uiState = ref.watch(chatUiProvider);
    var active = ref.watch(activeSessionProvider);

    var sessionId = active?.id ?? 0;
    if (sessionId <= 0) {
      active = Session(title: content, model: uiState.model.value);
      // final id = await db.sessionDao.upsertSession(active);
      active = await ref
          .read(sessionStateNotifierProvider.notifier)
          .upsertSesion(active);
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
    final uiState = ref.watch(chatUiProvider);
    ref.read(chatUiProvider.notifier).setRequestLoading(true);
    final messages = ref.watch(activeSessionMessagesProvider);
    final activeSession = ref.watch(activeSessionProvider);
    try {
      final id = uuid.v4();
      await chatgpt.streamChat(
        messages,
        model: activeSession?.model.toModel() ?? uiState.model,
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
