import 'package:chatgpt/widgets/chat_history.dart';
import 'package:chatgpt/widgets/chat_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => ChatScreen(),
  ),
  GoRoute(
    path: '/history',
    builder: (context, state) => ChatHistory(),
  )
]);
