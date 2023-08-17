import 'dart:async';
import 'dart:io';

import 'package:chatgpt/intl.dart';
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
    title: title ?? AppIntl.of(context).errorLabel,
    text: message,
    widget: child,
    confirmBtnText: AppIntl.of(context).ok,
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
  } on CancelledException catch (e) {
    logger.e("err: $e", error: e);
  } on OpenaiException catch (e) {
    logger.e("err: $e", error: e);
    final msg = errorMessageFromCode(context, e.code);
    showErrorDialog(
      context,
      message: msg ?? e.error.message,
    );
  } on HandshakeException catch (err) {
    showErrorDialog(
      context,
      message: AppIntl.of(context).errorMessageNetworkError,
    );
    logger.e("err: $err", error: err);
  } on SocketException catch (err) {
    showErrorDialog(
      context,
      message: AppIntl.of(context).errorMessageNetworkError,
    );
    logger.e("err: $err", error: err);
  } catch (err) {
    showErrorDialog(
      context,
      message: err.toString(),
    );
    logger.e("err: $err", error: err);
  } finally {
    finallyFn?.call();
  }
}

String? errorMessageFromCode(BuildContext context, int code) {
  switch (code) {
    case 401:
      return AppIntl.of(context).errorMassgeInvalidApiKey;
    default:
  }
  return null;
}
