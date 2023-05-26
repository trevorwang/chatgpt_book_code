import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/chat_ui_state.dart';
import '../states/session_state.dart';
import 'chat_gpt_model_widget.dart';
import 'chat_input.dart';
import 'chat_message_list.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SelectionArea(
        child: Column(
          children: [
            GptModelWidget(
              active: activeSession?.model.toModel(),
              onModelChanged: (model) {
                ref.read(chatUiProvider.notifier).model = model;
              },
            ),
            const Expanded(
              // 聊天消息列表
              child: ChatMessageListWidget(),
            ),

            // 输入框
            const ChatInputWidget(),
          ],
        ),
      ),
    );
  }
}
