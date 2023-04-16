import 'package:chatgpt/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/session_state.dart';

class ChatHistoryList extends HookConsumerWidget {
  const ChatHistoryList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionWithMessageProvider);
    return sessionState.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        data: (data) {
          return ListView(
            children: [
              for (var session in data.sessions)
                ListTile(
                  title: Text(
                    session.title,
                    maxLines: 1,
                  ),
                  leading: const Icon(Icons.messenger_outline),
                  selected: data.active?.id == session.id,
                  onTap: () {
                    ref
                        .read(sessionWithMessageProvider.notifier)
                        .active(session)
                        .then((value) {
                      if (isDesktop()) return;
                      GoRouter.of(context).pop();
                    });
                  },
                ),
            ],
          );
        },
        error: (err, stack) => Text("$err - $stack"),
        loading: () {
          return const CircularProgressIndicator();
        });
  }
}

class ChatHistoryScreen extends HookConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: const ChatHistoryList(),
    );
  }
}
