import 'package:chatgpt/states/session_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';

part 'message_state.g.dart';

class MessageList extends StateNotifier<List<Message>> {
  MessageList() : super([]) {
    init();
  }

  Future<void> init() async {}

  void upsertMessage(Message partialMessage) {
    final index =
        state.indexWhere((element) => element.id == partialMessage.id);
    var message = partialMessage;

    if (index >= 0) {
      final msg = state[index];
      message = partialMessage.copyWith(
          content: msg.content + partialMessage.content);
    }
    logger.d("message id ${message.toString()}");
    // update db
    db.messageDao.upsertMessage(message);

    if (index == -1) {
      state = [...state, message];
    } else {
      state = [...state]..[index] = message;
    }
  }
}

final messageProvider = StateNotifierProvider<MessageList, List<Message>>(
  (ref) => MessageList(),
);

@riverpod
FutureOr<List<Message>> sessionMessages(
    SessionMessagesRef ref, Session session) async {
  return await db.messageDao.findMessagesBySessionId(session.id!);
}

@riverpod
List<Message> activeSessionMessages(ActiveSessionMessagesRef ref) {
  final active = ref.watch(activeSessionProvider);
  if (active == null) {
    return [];
  }
  final messages = ref.watch(sessionMessagesProvider(active)).valueOrNull ?? [];
  return messages;
}
