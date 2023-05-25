import 'package:flutter/material.dart';

class LineBreakAction extends Action {
  final TextEditingController controller;
  LineBreakAction({
    required this.controller,
  }) : super();

  @override
  Object? invoke(Intent intent) {
    controller.text += "\n";
    controller.selection = TextSelection.fromPosition(
      TextPosition(
        offset: controller.text.length,
      ),
    );
    return null;
  }
}

class SentAction extends Action {
  final VoidCallback callback;
  SentAction({
    required this.callback,
  }) : super();
  @override
  Object? invoke(Intent intent) {
    callback();
    return null;
  }
}
