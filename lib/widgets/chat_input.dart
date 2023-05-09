import 'package:chatgpt/widgets/chat_gpt_model_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../states/chat_ui_state.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';

class ChatInputWidget extends HookConsumerWidget {
  const ChatInputWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceMode = useState(false);
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              voiceMode.value = !voiceMode.value;
            },
            icon: Icon(
              voiceMode.value ? Icons.keyboard : Icons.keyboard_voice,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Expanded(
            child: voiceMode.value
                ? const AudioInputWidget()
                : const TextInputWidget(),
          ),
        ],
      ),
    );
  }
}

class AudioInputWidget extends HookConsumerWidget {
  const AudioInputWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = useState(false);
    final transcripting = useState(false);
    final uiState = ref.watch(chatUiProvider);
    return SizedBox(
      height: 36,
      child: transcripting.value || uiState.requestLoading
          ? ElevatedButton(
              onPressed: null,
              child:
                  Text(transcripting.value ? "Transcripting..." : "Loading..."))
          : GestureDetector(
              onLongPressStart: (details) {
                recording.value = true;
                recorder.start();
              },
              onLongPressEnd: (details) async {
                recording.value = false;
                final path = await recorder.stop();
                if (path != null) {
                  try {
                    transcripting.value = true;
                    final text = await chatgpt.speechToText(path);
                    transcripting.value = false;
                    if (text.trim().isNotEmpty) {
                      await __sendMessage(ref, text);
                    }
                  } catch (err) {
                    logger.e("err: $err", err);
                    transcripting.value = false;
                  }
                }
              },
              onLongPressCancel: () {
                recording.value = false;
                recorder.stop();
              },
              child: ElevatedButton(
                onPressed: () {},
                child: Text(recording.value ? "Recording..." : "Hold to speak"),
              ),
            ),
    );
  }
}

class TextInputWidget extends HookConsumerWidget {
  const TextInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final uiState = ref.watch(chatUiProvider);
    return TextField(
      enabled: !uiState.requestLoading,
      controller: controller,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          hintText: 'Type a message', // 显示在输入框内的提示文字
          suffixIcon: IconButton(
            onPressed: () {
              // 这里处理发送事件
              if (controller.text.isNotEmpty) {
                _sendMessage(ref, controller);
              }
            },
            icon: const Icon(
              Icons.send,
            ),
          )),
    );
  }
}

// 增加WidgetRef
_sendMessage(WidgetRef ref, TextEditingController controller) async {
  final content = controller.text;
  controller.clear();
  return __sendMessage(ref, content);
}

__sendMessage(WidgetRef ref, String content) async {
  Message message = _createMessage(content);
  final uiState = ref.watch(chatUiProvider);
  var active = ref.watch(activeSessionProvider);

  var sessionId = active?.id ?? 0;
  if (sessionId <= 0) {
    active = Session(title: content, model: uiState.model.value);
    // final id = await db.sessionDao.upsertSession(active);
    active = await ref
        .read(sessionStateNotifierProvider.notifier)
        .upsertSesion(active);
    sessionId = active.id!;
    ref
        .read(sessionStateNotifierProvider.notifier)
        .setActiveSession(active.copyWith(id: sessionId));
  }

  ref.read(messageProvider.notifier).upsertMessage(
        message.copyWith(sessionId: sessionId),
      ); // 添加消息

  _requestChatGPT(ref, content, sessionId: sessionId);
}

Message _createMessage(
  String content, {
  String? id,
  bool isUser = true,
  int? sessionId,
}) {
  final message = Message(
    id: id ?? uuid.v4(),
    content: content,
    isUser: isUser,
    timestamp: DateTime.now(),
    sessionId: sessionId ?? 0,
  );
  return message;
}

_requestChatGPT(
  WidgetRef ref,
  String content, {
  int? sessionId,
}) async {
  final uiState = ref.watch(chatUiProvider);
  ref.read(chatUiProvider.notifier).setRequestLoading(true);
  final messages = ref.watch(activeSessionMessagesProvider);
  final activeSession = ref.watch(activeSessionProvider);
  try {
    final id = uuid.v4();
    await chatgpt.streamChat(
      messages,
      model: activeSession?.model.toModel() ?? uiState.model,
      onSuccess: (text) {
        final message =
            _createMessage(text, id: id, isUser: false, sessionId: sessionId);
        ref.read(messageProvider.notifier).upsertMessage(message);
      },
    );
  } catch (err) {
    logger.e("requestChatGPT error: $err", err);
  } finally {
    ref.read(chatUiProvider.notifier).setRequestLoading(false);
  }
}
