import 'package:chatgpt/env.dart';
import 'package:openai_api/openai_api.dart';

import '../models/message.dart';

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

  Future streamChat({
    List<Message> messages = const [],
    Function(String text)? onSuccess,
  }) async {
    final request = ChatCompletionRequest(
      model: Model.gpt3_5Turbo,
      stream: true,
      messages: messages
          .map((e) => ChatMessage(
                content: e.content,
                role:
                    e.isUser ? ChatMessageRole.user : ChatMessageRole.assistant,
              ))
          .toList(),
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
