import 'package:chatgpt/env.dart';
import 'package:chatgpt/models/message.dart';
import 'package:chatgpt/states/settings_state.dart';
import 'package:openai_api/openai_api.dart';
import 'package:tiktoken/tiktoken.dart';

import '../injection.dart';

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
      baseUrl: settings.baseUrl,
      httpProxy: settings.httpProxy,
    ));
  }

  Future<ChatCompletionResponse> sendChat(String content) async {
    final request = ChatCompletionRequest(model: Model.gpt3_5Turbo, messages: [
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
    Model model = Model.gpt3_5Turbo,
  }) async {
    final request = ChatCompletionRequest(
      model: model,
      stream: true,
      messages: messages.toChatMessages().limitMessages(),
    );
    return await client.sendChatCompletionStream(
      request,
      onSuccess: (p0) {
        final text = p0.choices.first.delta?.content;
        if (text != null) {
          onSuccess?.call(text);
        }
      },
    );
  }

  Future<String> speechToText(String path) async {
    final res =
        await client.createTrascription(TranscriptionRequest(file: path));
    logger.v(res);
    return res.text;
  }
}

final maxTokens = {
  Model.gpt3_5Turbo: 4096 - 200,
  Model.gpt4: 8192 - 300,
};

extension on List<ChatMessage> {
  List<ChatMessage> limitMessages({Model model = Model.gpt3_5Turbo}) {
    assert(maxTokens[model] != null, 'Model not supported');
    var messages = <ChatMessage>[];
    final encoding = encodingForModel(model.value);
    final maxToken = maxTokens[model]!;
    var count = 0;
    if (isEmpty) return messages;
    for (var i = length - 1; i >= 0; i--) {
      final m = this[i];
      count = count + encoding.encode(m.role.toString() + m.content).length;
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
