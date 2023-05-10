import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openai_api/openai_api.dart';
import 'package:quickalert/quickalert.dart';

import '../injection.dart';

void showErrorDialog(
  BuildContext context, {
  DialogType type = DialogType.error,
  String? title,
  String? message,
  Widget? child,
}) async {
  await QuickAlert.show(
    context: context,
    type: type,
    title: title,
    text: message,
    widget: child,
  );
}

typedef DialogType = QuickAlertType;

void handleError(
  BuildContext context,
  FutureOr Function() fn, {
  void Function()? finallyFn,
}) async {
  try {
    await fn();
  } on OpenaiException catch (e) {
    logger.e("err: $e", e);
    showErrorDialog(
      context,
      type: DialogType.error,
      title: "Error",
      message: e.error.message,
    );
  } catch (err) {
    showErrorDialog(
      context,
      type: DialogType.error,
      title: "Error",
      message: err.toString(),
    );
    logger.e("err: $err", err);
  } finally {
    finallyFn?.call();
  }
}
