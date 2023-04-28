import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
                for (var i in state.sessionList) ChatHistoryItemWidget(i: i),
              ]);
            },
            error: (err, stack) => Text("$err"),
            loading: () => const CircularProgressIndicator()),
      ),
    );
  }
}

class ChatHistoryItemWidget extends HookConsumerWidget {
  const ChatHistoryItemWidget({
    super.key,
    required this.i,
  });

  final Session i;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateNotifierProvider).valueOrNull;
    final editMode = useState(false);
    final controller = useTextEditingController();
    controller.text = i.title;
    return ListTile(
      title: editMode.value
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final text = controller.text;
                    if (text.trim().isNotEmpty) {
                      ref
                          .read(sessionStateNotifierProvider.notifier)
                          .upsertSesion(
                            i.copyWith(title: text.trim()),
                          );
                      editMode.value = false;
                    }
                  },
                  icon: const Icon(Icons.save),
                ),
                IconButton(
                  onPressed: () {
                    editMode.value = false;
                  },
                  icon: const Icon(Icons.cancel),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(i.title),
                ),
                IconButton(
                  onPressed: () {
                    editMode.value = true;
                  },
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
        ref.read(sessionStateNotifierProvider.notifier).setActiveSession(i);
        Navigator.of(context).pop();
      },
      selected: state?.activeSession?.id == i.id,
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
