import 'package:chatgpt/models/message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final List<Message> messages = [
    Message(content: "Hello", isUser: true, timestamp: DateTime.now()),
    Message(content: "How are you?", isUser: false, timestamp: DateTime.now()),
    Message(
        content: "Fine,Thank you. And you?",
        isUser: true,
        timestamp: DateTime.now()),
    Message(content: "I am fine.", isUser: false, timestamp: DateTime.now()),
  ];
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
                        _sendMessage(_textController.text);
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

  _sendMessage(String content) {
    final message =
        Message(content: content, isUser: true, timestamp: DateTime.now());
    messages.add(message);
    _textController.clear();
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
