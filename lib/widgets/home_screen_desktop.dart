import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatgpt/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
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
          color: const Color(0xFFF6F6F6),
          child: Stack(
            children: [
              Row(
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
                          child: ChatHistoryList(),
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
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF1F1F1),
                      padding: const EdgeInsets.all(8),
                      child: const ChatWindowScreen(),
                    ),
                  ),
                ],
              ),
              WindowTitleBarBox(
                child: Row(
                  children: [
                    Expanded(child: MoveWindow()),
                    const WindowButtons()
                  ],
                ),
              ) //
            ],
          ),
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
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
            alignment: Alignment.centerLeft,
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            iconColor: MaterialStateProperty.all(Colors.black),
            foregroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () {
            ref.read(sessionWithMessageProvider.notifier).active(null);
          },
          icon: const Icon(
            Icons.add,
            size: 16,
          ),
          label: const Text("New chat"),
        ),
      ),
    );
  }
}
