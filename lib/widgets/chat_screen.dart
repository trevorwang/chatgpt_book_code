import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/chat_ui_state.dart';
import '../states/session_state.dart';
import 'chat_gpt_model_widget.dart';
import 'chat_input.dart';
import 'chat_message_list.dart';

class ChatWindowScreen extends HookConsumerWidget {
  const ChatWindowScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    return Container(
      padding: const EdgeInsets.all(8.0),
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
          const Divider(
            indent: 0,
            height: 16,
          ),
          // 输入框
          const ChatInputWidget(),
        ],
      ),
    );
  }
}

extension ModelLabel on Model {
  String get label {
    switch (this) {
      case Model.gpt3_5Turbo:
        return 'GPT-3.5';
      case Model.gpt4:
        return 'GPT-4';
      default:
        return value;
    }
  }
}

extension ModelString on String {
  Model toModel() {
    return Model.values.where((e) => e.value == this).firstOrNull ??
        Model.gpt3_5Turbo;
  }
}
