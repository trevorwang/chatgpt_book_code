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
    return Column(
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
              ref.read(sessionWithMessageProvider.notifier).active(null);
            },
            child: const Text("New chat"),
          ),
        ),
        Expanded(
          child: sessionState.when(
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              data: (data) {
                return ListView(
                  children: [
                    for (var session in data.sessions)
                      ListTile(
                        // selectedColor: Colors.white,
                        // textColor: Colors.white,
                        // selectedTileColor: Colors.red,
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
              }),
        ),
      ],
    );
  }
}
