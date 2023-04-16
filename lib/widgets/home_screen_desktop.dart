import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/session_state.dart';
import 'chat_history.dart';
import 'chat_screen.dart';

class HomeScreenDesktop extends HookConsumerWidget {
  const HomeScreenDesktop({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: WindowBorder(
        color: Colors.grey,
        child: Container(
          color: const Color(0xFFF1F1F1),
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          const NewChatButton(),
                          const Expanded(
                            child: ChatHistoryList(),
                          ),
                          ListTile(
                            title: const Text("Settings"),
                            onTap: () {},
                          )
                        ],
                      )),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: const ChatWindowScreen(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: MoveWindow(
                  child: Container(),
                ),
              ),
            ],
          ),
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
        height: 32,
        child: OutlinedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onPressed: () {
            ref.read(sessionWithMessageProvider.notifier).active(null);
          },
          child: const Text("New chat"),
        ),
      ),
    );
  }
}
