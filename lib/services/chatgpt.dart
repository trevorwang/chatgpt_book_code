import 'package:chatgpt/env.dart';
import 'package:chatgpt/models/message.dart';
import 'package:openai_api/openai_api.dart';
import 'package:tiktoken/tiktoken.dart';

class ChatGPTService {
  final client = OpenaiClient(
    config: OpenaiConfig(
      apiKey: Env.apiKey,
      baseUrl: Env.baseUrl,
      httpProxy: Env.httpProxy,
    ),
  );

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
  }) async {
    final request = ChatCompletionRequest(
      model: Model.gpt3_5Turbo,
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
}

final maxTokens = {
  Model.gpt3_5Turbo: 4096,
  Model.gpt4: 8192,
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
