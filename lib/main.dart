import 'package:flutter/material.dart';
import 'package:flutter_tiktoken/flutter_tiktoken.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'injection.dart';
import 'router.dart';
import 'states/settings_state.dart';
import 'theme.dart';
import 'utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TiktokenDataProcessCenter().initata();
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
    final settings = ref.watch(settingStateProvider).valueOrNull;
    return MaterialApp.router(
      locale: settings?.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: settings?.appTheme,
      routerConfig: router,
    );
  }
}
