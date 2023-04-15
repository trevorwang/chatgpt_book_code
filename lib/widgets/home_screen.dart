import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/session_state.dart';
import 'chat_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => GoRouter.of(context).push('/history'),
        ),
        title: const Text('Chat'),
        actions: [
          // new button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(sessionWithMessageProvider.notifier).active(null);
            },
          ),

          // PopupMenuButton<String>(
          //   icon: const Icon(Icons.more_vert_outlined),
          //   initialValue: "",
          //   // Callback that sets the selected popup menu item.
          //   onSelected: (String item) {},
          //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       value: "1",
          //       child: const Text('History'),
          //       onTap: () => GoRouter.of(context).go('/history'),
          //     ),
          //   ],
          // ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              GoRouter.of(context).push('/settings');
            },
          )
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: ChatWindowScreen(),
      ),
    );
  }
}
