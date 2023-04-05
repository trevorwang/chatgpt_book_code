import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/message.dart';

class MessageList extends StateNotifier<List<Message>> {
  MessageList() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  void upsertMessage(Message partialMessage) {
    final index =
        state.indexWhere((element) => element.id == partialMessage.id);
    if (index == -1) {
      state = [...state, partialMessage];
    } else {
      final msg = state[index];
      state = [...state]..[index] = partialMessage.copyWith(
          content: msg.content + partialMessage.content);
    }
  }
}

final messageProvider = StateNotifierProvider<MessageList, List<Message>>(
  (ref) => MessageList(),
);
