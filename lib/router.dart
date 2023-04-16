import 'package:chatgpt/widgets/home_screen_desktop.dart';
import 'package:go_router/go_router.dart';

import 'widgets/chat_history.dart';
import 'widgets/home_screen.dart';
import 'widgets/settings_screen.dart';

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
        GoRoute(
          path: "settings",
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

final desktopRouter = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const HomeScreenDesktop(),
  ),
  GoRoute(
    path: "/settings",
    builder: (context, state) => const SettingsScreen(),
  ),
]);
