import 'package:chatgpt/injection.dart';
import 'package:chatgpt/models/message.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/messge_state.dart';

class ChatScreen extends HookConsumerWidget {
  final _textController = TextEditingController();
  ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              // 聊天消息列表
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return MessageItem(message: messages[index]);
                },
                itemCount: messages.length, // 消息数量
                separatorBuilder: (context, index) => const Divider(
                  // 分割线
                  height: 16,
                ),
              ),
            ),
            // 输入框
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  hintText: 'Type a message', // 显示在输入框内的提示文字
                  suffixIcon: IconButton(
                    onPressed: () {
                      // 这里处理发送事件
                      if (_textController.text.isNotEmpty) {
                        _sendMessage(ref, _textController.text);
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // 增加WidgetRef
  _sendMessage(WidgetRef ref, String content) {
    final message =
        Message(content: content, isUser: true, timestamp: DateTime.now());
    ref.read(messageProvider.notifier).addMessage(message); // 添加消息
    _textController.clear();
    _requestChatGPT(ref, content);
  }

  _requestChatGPT(WidgetRef ref, String content) async {
    final res = await chatgpt.sendChat(content);
    final text = res.choices.first.message?.content ?? "";
    final message =
        Message(content: text, isUser: false, timestamp: DateTime.now());
    ref.read(messageProvider.notifier).addMessage(message);
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
      children: [
        CircleAvatar(
          backgroundColor: message.isUser ? Colors.blue : Colors.blueGrey,
          child: Text(
            message.isUser ? 'A' : 'GPT',
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(message.content),
      ],
    );
  }
}
