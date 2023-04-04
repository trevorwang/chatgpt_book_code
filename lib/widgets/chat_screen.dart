import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
                  return Row(
                    children: [
                      const CircleAvatar(
                        child: Text('A'),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text('Message $index'),
                    ],
                  );
                },
                itemCount: 5, // 消息数量
                separatorBuilder: (context, index) => const SizedBox(
                  height: 8,
                ),
              ),
            ),
            // 输入框
            TextField(
              decoration: InputDecoration(
                  hintText: 'Type a message', // 显示在输入框内的提示文字
                  suffixIcon: IconButton(
                    onPressed: () {
                      // 这里处理发送事件
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
}
