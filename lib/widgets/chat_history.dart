import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session.dart';
import '../states/session_state.dart';

class ChatHistory extends HookConsumerWidget {
  const ChatHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: Center(
        child: state.when(
            data: (state) {
              return ListView(children: [
                for (var i in state.sessionList)
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(i.title),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteConfirm(context, ref, i);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                    onTap: () {
                      ref
                          .read(sessionStateNotifierProvider.notifier)
                          .setActiveSession(i);
                      Navigator.of(context).pop();
                    },
                    selected: state.activeSession?.id == i.id,
                  ),
              ]);
            },
            error: (err, stack) => Text("$err"),
            loading: () => const CircularProgressIndicator()),
      ),
    );
  }
}

Future _deleteConfirm(
    BuildContext context, WidgetRef ref, Session session) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: const Text("Are you sure to delete?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(sessionStateNotifierProvider.notifier)
                    .deleteSession(session);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      });
}
