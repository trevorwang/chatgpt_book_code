import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TypingCursor extends HookWidget {
  const TypingCursor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ac = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    ac.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ac.reverse();
      } else if (status == AnimationStatus.dismissed) {
        ac.forward();
      }
    });

    final opacity = useAnimation(Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(ac));
    if (!ac.isAnimating) {
      ac.forward();
    }
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        width: 6,
        height: 12,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }
}
