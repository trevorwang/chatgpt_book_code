import 'package:chatgpt/widgets/chat_input.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VoiceChatScreen extends HookConsumerWidget {
  const VoiceChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      children: [
        SizedBox(height: 16),
        AudioInputWidget(),
        SizedBox(height: 16),
        Text('Coming soon...'),
      ],
    );
  }
}

enum VoiceChatState {
  idle,
  recording,
  transcripting,
  querying,
  speaking,
  playing,
}
