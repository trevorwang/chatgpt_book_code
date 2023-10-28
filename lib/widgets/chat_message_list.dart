import 'package:chatgpt/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown/code_wrapper.dart';
import '../markdown/latex.dart';
import '../models/message.dart';
import '../states/message_state.dart';
import '../states/chat_ui_state.dart';
import '../theme.dart';
import '../colors.dart';
import '../injection.dart';
import '../states/session_state.dart';
import '../tools/error.dart';
import '../tools/files.dart';
import '../tools/share.dart';
import '../utils.dart';
import 'typing_cursor.dart';

class ChatMessageListWidget extends HookConsumerWidget {
  const ChatMessageListWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSessionProvider);
    final scrollController = useScrollController();
    final uiState = ref.watch(chatUiProvider);
    final chatListKey = GlobalKey();
    return Column(
      key: chatListKey,
      children: [
        Expanded(
          child: ChatMessageList(
            listController: scrollController,
          ),
        ),
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (uiState.requestLoading)
                ElevatedButton.icon(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.red)),
                  onPressed: () {
                    if (uiState.requestLoading) {
                      uiState.cancellationToken?.cancel();
                    }
                  },
                  icon: const Icon(Icons.stop),
                  label: Text(AppIntl.of(context).stopResponsing),
                ),
              IconButton(
                onPressed: () {
                  if (active != null) {
                    handleError(context, () async {
                      if (isDesktop()) {
                        final path =
                            await saveAs(fileName: "${active.title}.md");
                        if (path == null) return; //取消选择
                        exportService.exportMarkdown(
                          active,
                          path: path,
                        );
                      } else {
                        final output =
                            await exportService.exportMarkdown(active);
                        if (output == null) return;
                        shareFiles([output]);
                      }
                    });
                  }
                },
                icon: const Icon(Icons.text_snippet),
              ),
              IconButton(
                onPressed: () {
                  if (active != null) {
                    final renderbox = chatListKey.currentContext!
                        .findRenderObject() as RenderBox;

                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.linear,
                    );
                    // Future.delayed(const Duration(milliseconds: 500));
                    final height = scrollController.position.maxScrollExtent +
                        scrollController.position.viewportDimension;
                    handleError(context, () async {
                      if (isDesktop()) {
                        final path =
                            await saveAs(fileName: "${active.title}.png");
                        if (path == null) return;
                        exportService.exportImage(
                          active,
                          context: ref.context,
                          targetSize:
                              Size(renderbox.size.width + 32, height + 48),
                          path: path,
                        );
                      } else {
                        final output = await exportService.exportImage(
                          active,
                          context: ref.context,
                          targetSize:
                              Size(renderbox.size.width + 32, height + 48),
                        );
                        if (output == null) return;
                        shareFiles([output]);
                      }
                    });
                  }
                },
                icon: const Icon(Icons.image),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ChatMessageList extends HookConsumerWidget {
  final ScrollController listController;
  const ChatMessageList({
    super.key,
    required this.listController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(activeSessionMessagesProvider);
    final uiState = ref.watch(chatUiProvider);

    ref.listen(activeSessionMessagesProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 200), () {
        listController.jumpTo(
          listController.position.maxScrollExtent,
        );
        logger.v(
            "jump to bottom......${listController.position.maxScrollExtent}");
      });
    });
    return ListView.separated(
      controller: listController,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return msg.isUser
            ? SentMessageItem(
                message: msg,
                backgroundColor: isDarkMode(context)
                    ? sentMessageBgDark
                    : sentMessageBgLight,
              )
            : ReceivedMessageItem(
                backgroundColor: isDarkMode(context)
                    ? receivedMessageBgDark
                    : receivedMessageBgLight,
                message: msg,
                typing: index == messages.length - 1 && uiState.requestLoading,
              );
      },
      itemCount: messages.length, // 消息数量
      separatorBuilder: (context, index) => const Divider(
        // 分割线
        height: 16,
        color: Colors.transparent,
      ),
    );
  }
}

class ReceivedMessageItem extends StatelessWidget {
  final Color backgroundColor;
  final double radius;
  final bool typing;
  const ReceivedMessageItem({
    super.key,
    required this.message,
    this.backgroundColor = Colors.white,
    this.radius = 8,
    this.typing = false,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          child: SvgPicture.asset(
            "assets/images/chatgpt.svg",
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        CustomPaint(
          painter: Triagnle(backgroundColor),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.only(right: 48),
            child: MessageContentWidget(
              message: message,
              typing: typing,
            ),
          ),
        ),
      ],
    );
  }
}

class SentMessageItem extends StatelessWidget {
  final Color backgroundColor;
  final double radius;
  const SentMessageItem({
    super.key,
    required this.message,
    this.backgroundColor = Colors.white,
    this.radius = 8,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.only(left: 48),
            child: MessageContentWidget(
              message: message,
            ),
          ),
        ),
        CustomPaint(
          painter: Triagnle(backgroundColor),
        ),
        const SizedBox(
          width: 8,
        ),
        const CircleAvatar(
            child: Text(
          'A',
        )),
      ],
    );
  }
}

class MessageContentWidget extends StatelessWidget {
  final bool typing;
  const MessageContentWidget({
    super.key,
    required this.message,
    this.typing = false,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    codeWrapper(child, text) => CodeWrapperWidget(child: child, text: text);

    final config = isDarkMode(context)
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...MarkdownGenerator(
          generators: [
            latexGenerator,
          ],
          inlineSyntaxList: [
            LatexSyntax(),
          ],
        ).buildWidgets(message.content,
            config: config.copy(configs: [
              config.pre.copy(wrapper: codeWrapper),
            ])),
        if (typing) const TypingCursor(),
      ],
    );
  }
}

class Triagnle extends CustomPainter {
  final Color bgColor;

  Triagnle(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(5, 10);
    path.lineTo(10, 0);
    canvas.translate(-5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
