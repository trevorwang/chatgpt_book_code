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

@riverpod
class ChatUiSate extends _$ChatUiSate {
  @override
  ChatState build() {
    return const ChatState(
      requestLoading: false,
      model: Model.gpt3_5Turbo,
      voiceMode: false,
      recording: false,
    );
  }

  set model(Model model) {
    state = ChatUiState(
      model: model,
    );
  }
}

  void setRequestLoading(bool loading) {
    state = state.copyWith(requestLoading: loading);
  }

  set model(Model model) {
    state = state.copyWith(model: model);
  }

  set voiceMode(bool voiceMode) {
    state = state.copyWith(voiceMode: voiceMode);
  }

  set recording(bool recording) {
    state = state.copyWith(recording: recording);
  }
}
