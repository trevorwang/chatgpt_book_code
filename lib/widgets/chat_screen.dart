import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'chat_history.dart';
import 'chat_message_list.dart';
import 'chat_user_input.dart';

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
            const SizedBox(width: 16),
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
