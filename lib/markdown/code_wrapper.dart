import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CodeWrapperWidget extends HookWidget {
  final Widget child;
  final String text;
  const CodeWrapperWidget({
    super.key,
    required this.child,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final hasCopied = useState(false);

    final switchIcon = Icon(hasCopied.value ? Icons.check : Icons.copy_rounded,
        key: UniqueKey());
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
                if (hasCopied.value) return;
                await Clipboard.setData(ClipboardData(text: text));
                hasCopied.value = true;
                Future.delayed(const Duration(seconds: 1), () {
                  hasCopied.value = false;
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
