import 'package:chatgpt/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/session_state.dart';
import 'chat_history.dart';
import 'chat_screen.dart';
import 'desktop.dart';

class DesktopHomeScreen extends StatelessWidget {
  const DesktopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DesktopWindow(
        child: Row(
          children: [
            SizedBox(
                width: 240,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const NewChatButton(),
                    const SizedBox(
                      height: 8,
                    ),
                    const Expanded(
                      child: ChatHistoryWindow(),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                  title: Text("Settings"),
                                  content: SizedBox(
                                    height: 400,
                                    width: 400,
                                    child: SettingsWindow(),
                                  ));
                            });
                      },
                    )
                  ],
                )),
            const Expanded(child: ChatScreen()),
          ],
        ),
      ),
    );
  }
}

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
              ref
                  .read(sessionStateNotifierProvider.notifier)
                  .setActiveSession(null);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: const ChatScreen(),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                "Chat History",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: const ChatHistoryWindow(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).push('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NewChatButton extends HookConsumerWidget {
  const NewChatButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: SizedBox(
        height: 40,
        child: OutlinedButton.icon(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              Theme.of(context).textTheme.titleMedium,
            ),
            iconSize:
                MaterialStateProperty.all(Theme.of(context).iconTheme.size),
            alignment: Alignment.centerLeft,
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            iconColor: MaterialStateProperty.all(
                Theme.of(context).textTheme.titleMedium?.color),
            foregroundColor: MaterialStateProperty.all(
                Theme.of(context).textTheme.titleMedium?.color),
          ),
          onPressed: () {
            ref
                .read(sessionStateNotifierProvider.notifier)
                .setActiveSession(null);
          },
          icon: const Icon(
            Icons.add,
          ),
          label: const Text("New chat"),
        ),
      ),
    );
  }
}
