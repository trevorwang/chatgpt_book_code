import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_api/openai_api.dart';

class ChatUiState {
  final bool requestLoading;
  final Model model;
  ChatUiState({
    this.requestLoading = false,
    this.model = Model.gpt3_5Turbo,
  });
}

class ChatUiStateProvider extends StateNotifier<ChatUiState> {
  ChatUiStateProvider() : super(ChatUiState());

  void setRequestLoading(bool requestLoading) {
    state = ChatUiState(
      requestLoading: requestLoading,
    );
  }

  set model(Model model) {
    state = ChatUiState(
      model: model,
    );
  }
}

final chatUiProvider = StateNotifierProvider<ChatUiStateProvider, ChatUiState>(
  (ref) => ChatUiStateProvider(),
);
