import 'package:chatgpt/states/chat_ui_state.dart';
import 'package:chatgpt/states/session_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_api/openai_api.dart';
import 'package:collection/collection.dart';

import 'chat_history.dart';
import 'chat_message_list.dart';
import 'chat_user_input.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(sessionWithMessageProvider
        .select((value) => value.valueOrNull?.active));
    final model = ref.watch(chatUiSateProvider).model;
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Model: '),
                      active == null
                          ? DropdownButton<Model>(
                              items: [Model.gpt3_5Turbo, Model.gpt4].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.label),
                                );
                              }).toList(),
                              value: model,
                              onChanged: (Model? item) {
                                if (item == null) return;
                                ref.read(chatUiSateProvider.notifier).model =
                                    item;
                              },
                            )
                          : Text(active.model),
                    ],
                  ),

                  const Expanded(
                    // 聊天消息列表
                    child: ChatMessageList(),
                  ),
                  // 输入框
                  const UserInputWidget(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension ModelString on String {
  Model toModel() {
    return Model.values.where((e) => e.value == this).firstOrNull ??
        Model.gpt3_5Turbo;
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
