import 'package:chatgpt/utils.dart';
import 'package:chatgpt/widgets/chat_history.dart';
import 'package:chatgpt/widgets/home_screen.dart';
import 'package:chatgpt/widgets/settings_screen.dart';
import 'package:go_router/go_router.dart';

final router = isDesktop() ? desktopRouter : mobileRouter;

final mobileRouter = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/history',
    builder: (context, state) => const ChatHistoryScreen(),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),
]);

final desktopRouter = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const DesktopHomeScreen(),
  ),
]);
