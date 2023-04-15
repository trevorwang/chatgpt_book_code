import 'package:chatgpt/env.dart';
import 'package:openai_api/openai_api.dart';

import '../injection.dart';
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
    Model model = Model.gpt3_5Turbo,
    Function(String text)? onSuccess,
  }) async {
    final request = ChatCompletionRequest(
      model: model,
      stream: true,
      messages: messages
          .map((e) => ChatMessage(
                content: e.content,
                role:
                    e.isUser ? ChatMessageRole.user : ChatMessageRole.assistant,
              ))
          .toList()
        ..insert(
            0,
            const ChatMessage(
                content:
                    "你是一个AI助手，可以回答用户输入的问题，输出格式同ChatGPT官方客户端一致。涉及到公式的部分，使用latex语法。",
                role: ChatMessageRole.system)),
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
