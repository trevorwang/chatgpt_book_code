import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final copyStateProvider = StateProvider((ref) => false);

class CodeWrapperWidget extends HookConsumerWidget {
  final Widget child;
  final String text;
  const CodeWrapperWidget({
    super.key,
    required this.child,
    required this.text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCopied = ref.watch(copyStateProvider);

    final switchIcon =
        Icon(hasCopied ? Icons.check : Icons.copy_rounded, key: UniqueKey());
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switchIcon,
              ),
              onTap: () async {
                if (hasCopied) return;
                await Clipboard.setData(ClipboardData(text: text));
                ref.read(copyStateProvider.notifier).state = true;
                Future.delayed(const Duration(seconds: 2), () {
                  ref.read(copyStateProvider.notifier).state = false;
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
