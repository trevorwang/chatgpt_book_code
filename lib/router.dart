import 'package:chatgpt/widgets/chat_history.dart';
import 'package:go_router/go_router.dart';

import 'widgets/home_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: "history",
          builder: (context, state) => const ChatHistoryScreen(),
        ),
      ],
    ),
  ],
);
