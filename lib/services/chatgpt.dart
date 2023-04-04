import 'package:chatgpt/env.dart';
import 'package:openai_api/openai_api.dart';

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
}
