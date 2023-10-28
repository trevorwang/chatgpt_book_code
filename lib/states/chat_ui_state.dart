import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_api/openai_api.dart';

part 'chat_ui_state.freezed.dart';

@freezed
class ChatUiState with _$ChatUiState {
  const factory ChatUiState({
    @Default(false) bool requestLoading,
    @Default(Models.gpt3_5Turbo) String model,
    CancellationToken? cancellationToken,
  }) = _ChatUiState;
}

class ChatUiStateProvider extends StateNotifier<ChatUiState> {
  ChatUiStateProvider() : super(const ChatUiState());

  void setRequestLoading(bool requestLoading) {
    state = state.copyWith(
      requestLoading: requestLoading,
    );
  }

  set model(String model) {
    state = state.copyWith(
      model: model,
    );
  }

  set cancellationToken(CancellationToken? cancellationToken) {
    state = state.copyWith(
      cancellationToken: cancellationToken,
    );
  }
}

final chatUiProvider = StateNotifierProvider<ChatUiStateProvider, ChatUiState>(
  (ref) => ChatUiStateProvider(),
);
