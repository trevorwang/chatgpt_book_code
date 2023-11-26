import 'package:openai_api/openai_api.dart';
import 'package:flutter_tiktoken/flutter_tiktoken.dart';

import '../injection.dart';
import '../models/message.dart';
import '../states/settings_state.dart';

class ChatGPTService {
  final client = OpenaiClient(
    config: OpenaiConfig(
      apiKey: '',
    ),
  );

  loadConfig() async {
    final settings = await Settings.load();
    client.updateConfig(client.config.copyWith(
      apiKey: settings.apiKey,
      baseUrl: settings.baseUrl?.isEmpty == true ? null : settings.baseUrl,
      httpProxy: settings.httpProxy,
    ));
  }

  Future chat(
    List<Message> messages, {
    Function(String text)? onSuccess,
    String model = Models.gpt3_5Turbo,
    CancellationToken? cancellationToken,
    bool textMode = true,
    bool stream = true,
  }) async {
    final systemMsg = textMode
        ? ChatMessage.system(
            content:
                "You're an AI assistant. Answer user's questions correctly. Response in Markdown format with LaTeX syntax if any formula.",
          )
        : ChatMessage.system(
            content:
                "You're an AI assistant. Answer user's questions correctly, shortly and as quickly as possible.");

    final request = ChatCompletionRequest(
      model: model,
      maxTokens: maxTokens[model],
      stream: stream,
      messages: messages.toChatMessages().limitMessages()
        ..insert(
          0,
          systemMsg,
        ),
    );

    if (stream) {
      return await client.sendChatCompletionStream(
        request,
        onSuccess: (p0) {
          final text = p0.choices.first.delta?.content;
          if (text != null) {
            onSuccess?.call(text);
          }
        },
        cancellationToken: cancellationToken,
      );
    } else {
      final res = await client.sendChatCompletion(
        request,
        cancellationToken: cancellationToken,
      );
      onSuccess?.call(res.choices.first.message?.content);
    }
  }

  Future<String> speechToText(
    String path, {
    CancellationToken? cancellationToken,
  }) async {
    final res = await client.createTranscription(
      TranscriptionRequest(file: path),
      cancellationToken: cancellationToken,
    );
    logger.v(res);
    return res.text;
  }

  Future<List<int>> textToSpeech(
    String text, {
    CancellationToken? cancellationToken,
  }) async {
    return await client.createSpeech(
      SpeechRequest(voice: 'alloy', input: text),
      cancellationToken: cancellationToken,
    );
  }
}

final maxTokens = {
  Models.gpt3_5Turbo: 4096 - 200,
  Models.gpt4: 8192 - 300,
  Models.gpt4_1106VisonPreview: 2000,
};

extension on List {
  List<ChatMessage> limitMessages({String model = Models.gpt3_5Turbo}) {
    assert(maxTokens[model] != null, 'Model not supported');
    var messages = <ChatMessage>[];
    final encoding = encodingForModel(model);
    final maxToken = maxTokens[model]!;
    var count = 0;
    if (isEmpty) return messages;
    for (var i = length - 1; i >= 0; i--) {
      final m = this[i];
      final content = m.content ?? "";
      count = count + encoding.encode(m.role.toString() + content).length;
      if (count <= maxToken) {
        messages.insert(0, m);
      }
    }
    return messages;
  }
}

extension on List<Message> {
  List<ChatMessage> toChatMessages() {
    return map(
      (e) => ChatMessage(
        content: e.content,
        role: e.isUser ? ChatMessageRole.user : ChatMessageRole.assistant,
      ),
    ).toList();
  }
}

extension on OpenaiConfig {
  OpenaiConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? httpProxy,
  }) {
    return OpenaiConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      httpProxy: httpProxy ?? this.httpProxy,
    );
  }
}
