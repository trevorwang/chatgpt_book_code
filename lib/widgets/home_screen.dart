import 'package:chatgpt/widgets/chat_screen.dart';
import 'package:chatgpt/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/session_state.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              GoRouter.of(context).push('/history');
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () {
              ref
                  .read(sessionStateNotifierProvider.notifier)
                  .setActiveSession(null);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
              onPressed: () {
                GoRouter.of(context).push('/settings');
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: const ChatScreen(),
    );
  }
}

class DesktopHomeScreen extends StatelessWidget {
  const DesktopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DesktopWindow(
        child: ChatScreen(),
      ),
    );
  }
}
