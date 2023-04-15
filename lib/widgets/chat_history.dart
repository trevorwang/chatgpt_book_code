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
                        .then(
                          (value) => GoRouter.of(context).pop(),
                        );
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
        body: Column(
          children: [
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  ref
                      .read(sessionWithMessageProvider.notifier)
                      .active(null)
                      .then((value) => GoRouter.of(context).pop());
                },
                child: const Text("New chat"),
              ),
            ),
            const Expanded(
              child: ChatHistoryList(),
            ),
          ],
        ));
  }
}
