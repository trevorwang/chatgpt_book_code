import 'package:chatgpt/widgets/chat_history.dart';
import 'package:chatgpt/widgets/chat_screen.dart';
import 'package:chatgpt/widgets/settings_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const ChatScreen(),
  ),
  GoRoute(
    path: '/history',
    builder: (context, state) => const ChatHistory(),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),
]);
