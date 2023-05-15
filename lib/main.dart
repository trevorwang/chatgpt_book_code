import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'injection.dart';
import 'router.dart';
import 'states/settings_state.dart';
import 'theme.dart';
import 'utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDatabse();
  await chatgpt.loadConfig();
  initWindow();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingStateProvider).valueOrNull?.appTheme;
    final theme = getThemeData(settings);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ChatGPT',
      theme: theme.item1,
      darkTheme: theme.item2,
      routerConfig: router,
    );
  }
}
