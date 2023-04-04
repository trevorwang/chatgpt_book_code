import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/message.dart';

class MessageList extends StateNotifier<List<Message>> {
  MessageList() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }
}

final messageProvider = StateNotifierProvider<MessageList, List<Message>>(
  (ref) => MessageList(),
);
