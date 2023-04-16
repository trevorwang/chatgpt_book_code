import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_api/openai_api.dart';
import 'package:quickalert/quickalert.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../states/chat_ui_state.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';
import 'chat_screen.dart';

List<Message> getValidMessages(WidgetRef ref, int sessionId) {
  final messageToSubmit = ref.watch(messageProvider.select((value) =>
      value.where((element) => element.sessionId == sessionId).toList()));

  final tokens = messageToSubmit.map((e) => e.content).join('\n');
  while (tokens.length > 3000 && messageToSubmit.length > 1) {
    messageToSubmit.removeAt(0);
  }
  return messageToSubmit;
}

Future<void> __sendMessage(WidgetRef ref, String content) async {
  var sessionId =
      ref.watch(sessionWithMessageProvider).valueOrNull?.active?.id ?? 0;
  final model = ref.watch(chatUiSateProvider).model;
  if (sessionId <= 0) {
    final session = await ref
        .read(sessionWithMessageProvider.notifier)
        .insertSession(Session(title: content, model: model.value));
    sessionId = session.id!;
  }
  final msg =
      _createMessage(uuid.v4(), content, isUser: true, sessionId: sessionId);
  ref.read(messageProvider.notifier).upsertMessage(msg);

  List<Message> messageToSubmit = getValidMessages(ref, sessionId);
  _requestChatGPT(ref, messageToSubmit, sessionId);
}

Message _createMessage(
  String id,
  String text, {
  bool isUser = false,
  int? sessionId,
}) {
  final message = Message(
    id: id,
    content: text,
    isUser: isUser,
    timestamp: DateTime.now(),
    sessionId: sessionId ?? 0,
  );
  return message;
}

_requestChatGPT(WidgetRef ref, List<Message> messages, int sessionId) async {
  ref.read(chatUiSateProvider.notifier).setRequestLoading(true);
  final activeSession =
      ref.watch(sessionWithMessageProvider).valueOrNull?.active;
  final model = ref.watch(chatUiSateProvider).model;
  try {
    final id = uuid.v4();
    await chatgpt.streamChat(
      messages: messages,
      model: activeSession?.model.toModel() ?? model,
      onSuccess: (text) {
        final msg = _createMessage(
          id,
          text,
          sessionId: sessionId,
        );
        ref.read(messageProvider.notifier).upsertMessage(msg);
      },
    );
  } on OpenaiException catch (err) {
    logger.e("requestChatGPT error: $err", err);

    QuickAlert.show(
        context: ref.context,
        type: QuickAlertType.error,
        text: err.error.message);
  } catch (err) {
    logger.e(" error: $err", err);

    QuickAlert.show(
        context: ref.context,
        type: QuickAlertType.error,
        text: "Unknown error");
  } finally {
    ref.read(chatUiSateProvider.notifier).setRequestLoading(false);
  }
}

class AudioInput extends HookConsumerWidget {
  const AudioInput({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = ref.watch(chatUiSateProvider).recording;
    final uiState = ref.read(chatUiSateProvider.notifier);
    final loading = ref.watch(chatUiSateProvider).requestLoading;
    return SizedBox(
      height: 48,
      child: loading
          ? ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onPressed: null,
              child: const Text("Transcripting..."),
            )
          : HoldDetector(
              onHold: () {
                logger.v("on hold.....");
                if (!recording) {
                  uiState.recording = true;
                  record.record();
                }
              },
              onCancel: () async {
                logger.v("on cancel.....");
                uiState.recording = false;
                final path = await record.stop();
                if (path != null) {
                  ref.read(chatUiSateProvider.notifier).setRequestLoading(true);
                  final text = await chatgpt.speechToText(Uri.parse(path).path);
                  ref
                      .read(chatUiSateProvider.notifier)
                      .setRequestLoading(false);
                  __sendMessage(ref, text);
                  logger.v("convert to text $text");
                }
              },
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onPressed: () {},
                child: Text(recording ? "Recording... " : "Hold to say"),
              ),
            ),
    );
  }
}

class TextInputWidget extends HookConsumerWidget {
  const TextInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUIState = ref.watch(chatUiSateProvider);
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    return TextField(
      minLines: 1,
      maxLines: 3,
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      onSubmitted: (value) {
        if (chatUIState.requestLoading) return;
        if (value.isNotEmpty) {
          _sendMessage(ref, controller, focusNode: focusNode);
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Send a message...', // 显示在输入框内的提示文字

        suffixIcon: SizedBox(
          width: 40,
          child: chatUIState.requestLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    // 这里处理发送事件
                    if (controller.text.isNotEmpty) {
                      _sendMessage(ref, controller, focusNode: focusNode);
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
        ),
      ),
    );
  }

  // 增加WidgetRef
  _sendMessage(
    WidgetRef ref,
    TextEditingController controller, {
    FocusNode? focusNode,
  }) async {
    final content = controller.text;

    controller.clear();
    focusNode?.requestFocus();
    await __sendMessage(ref, content);
  }
}

class UserInputWidget extends HookConsumerWidget {
  const UserInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceMode = ref.watch(chatUiSateProvider).voiceMode;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              ref.watch(chatUiSateProvider.notifier).voiceMode = !voiceMode;
            },
            icon: Icon(
              voiceMode ? Icons.keyboard : Icons.multitrack_audio,
              color: Colors.blue,
              size: 28,
            ),
          ),
          Expanded(
            child: SizedBox(
              child: voiceMode ? const AudioInput() : const TextInputWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
