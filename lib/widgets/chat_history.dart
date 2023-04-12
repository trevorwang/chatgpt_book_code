import 'package:flutter/material.dart';
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
              ListTile(
                title: ElevatedButton(
                  onPressed: () {
                    ref.read(sessionWithMessageProvider.notifier).active(null);
                  },
                  child: const Text("New Chat"),
                ),
              ),
              for (var session in data.sessions)
                ListTile(
                  title: Text(
                    session.title,
                    maxLines: 1,
                  ),
                  selected: data.active == session.id,
                  onTap: () {
                    ref
                        .read(sessionWithMessageProvider.notifier)
                        .active(session.id);
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
