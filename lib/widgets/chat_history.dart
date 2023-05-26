import 'package:chatgpt/intl.dart';
import 'package:chatgpt/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session.dart';
import '../states/session_state.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppIntl.of(context).chatHistoryTitle),
      ),
      body: const ChatHistoryWindow(),
    );
  }
}

class ChatHistoryWindow extends HookConsumerWidget {
  const ChatHistoryWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateNotifierProvider);
    return Center(
      child: state.when(
          data: (state) {
            return ListView(children: [
              for (var i in state.sessionList) ChatHistoryItemWidget(i: i),
            ]);
          },
          error: (err, stack) => Text("$err"),
          loading: () => const CircularProgressIndicator()),
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
    final hover = useState(false);
    controller.text = i.title;
    return MouseRegion(
      onEnter: (event) => hover.value = true,
      onExit: (event) => hover.value = false,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
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
                              .updateSesion(
                                i.copyWith(title: text.trim()),
                              );
                          editMode.value = false;
                        }
                      },
                      icon: const Icon(Icons.check_box),
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
                      child: Text(
                        i.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hover.value || !isDesktop())
                      IconButton(
                        onPressed: () {
                          editMode.value = true;
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    if (hover.value || !isDesktop())
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
            if (!isDesktop()) Navigator.of(context).pop();
          },
          selected: state?.activeSession?.id == i.id,
        ),
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
          title: Text(AppIntl.of(context).delete),
          content: Text(AppIntl.of(context).deleteConfirm),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppIntl.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(sessionStateNotifierProvider.notifier)
                    .deleteSession(session);
                ref
                    .read(sessionStateNotifierProvider.notifier)
                    .setActiveSession(null);
                Navigator.of(context).pop();
              },
              child: Text(AppIntl.of(context).delete),
            ),
          ],
        );
      });
}
