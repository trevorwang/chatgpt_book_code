import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openai_api/openai_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_ui_state.freezed.dart';
part 'chat_ui_state.g.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required bool requestLoading,
    required Model model,
    required bool voiceMode,
    required bool recording,
  }) = _ChatUiState;
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
