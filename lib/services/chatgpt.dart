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

  Future<ChatCompletionResponse> sendChat(String content) async {
    final request = ChatCompletionRequest(model: Models.gpt3_5Turbo, messages: [
      ChatMessage(
        content: content,
        role: ChatMessageRole.user,
      )
    ]);
    return await client.sendChatCompletion(request);
  }

  Future streamChat(
    List<Message> messages, {
    Function(String text)? onSuccess,
    String model = Models.gpt3_5Turbo,
    CancellationToken? cancellationToken,
  }) async {
    final request = ChatCompletionRequest(
      model: model,
      maxTokens: model == Models.gpt4_1106VisonPreview ? 2000 : null,
      stream: true,
      messages: messages.toChatMessages().limitMessages()
        ..insert(
          0,
          const ChatMessage(
            content:
                "You're an AI assistant. Answer user's questions correctly. Response in Markdown format with LaTeX syntax if any formula.",
            role: ChatMessageRole.system,
          ),
        ),
    );
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
  }

  Future<String> speechToText(
    String path, {
    CancellationToken? cancellationToken,
  }) async {
    final res = await client.createTrascription(
      TranscriptionRequest(file: path),
      cancellationToken: cancellationToken,
    );
    logger.v(res);
    return res.text;
  }
}

final maxTokens = {
  Models.gpt3_5Turbo: 4096 - 200,
  Models.gpt4: 8192 - 300,
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
