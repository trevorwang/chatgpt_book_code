import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../intl.dart';
import '../states/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppIntl.of(context).settingsTitle),
      ),
      body: const SettingsWindow(),
    );
  }
}

class SettingsWindow extends HookConsumerWidget {
  const SettingsWindow({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: const [
        SettingItemApiKey(),
        Divider(),
        SettingItemHttpProxy(),
        Divider(),
        SettingItemOpenAiBase(),
        Divider(),
        SettingItemAppTheme(),
        Divider(),
        SettingItemLanguage(),
      ],
    );
  }
}

class SettingItemHttpProxy extends HookConsumerWidget {
  const SettingItemHttpProxy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = AppIntl.of(context).settingsHttpProxyTitle;
    final settings = ref.watch(settingStateProvider).valueOrNull;
    final controller = useTextEditingController();
    return ListTile(
      title: Text(title),
      subtitle: Text(settings?.httpProxy ?? ""),
      onTap: () async {
        final text = await showEditor(
          controller,
          ref,
          title,
          text: settings?.httpProxy,
        );
        if (text == null) return;
        ref.read(settingStateProvider.notifier).setHttpProxy(text);
      },
    );
  }
}

class SettingItemApiKey extends HookConsumerWidget {
  const SettingItemApiKey({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = AppIntl.of(context).settingsApiKeyLabel;
    final settings = ref.watch(settingStateProvider).valueOrNull;
    final controller = useTextEditingController();
    return ListTile(
      title: Text(title),
      subtitle: Text(
        settings?.apiKey ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () async {
        final text = await showEditor(
          controller,
          ref,
          title,
          text: settings?.apiKey,
        );
        if (text == null) return;
        ref.read(settingStateProvider.notifier).setApiKey(text);
      },
    );
  }
}

class SettingItemOpenAiBase extends HookConsumerWidget {
  const SettingItemOpenAiBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = AppIntl.of(context).settingsOpenaiApiBase;
    final settings = ref.watch(settingStateProvider).valueOrNull;
    final controller = useTextEditingController();
    return ListTile(
      title: Text(title),
      subtitle: Text(settings?.baseUrl ?? ""),
      onTap: () async {
        final text = await showEditor(
          controller,
          ref,
          title,
          text: settings?.baseUrl,
        );
        if (text == null) return;
        ref.read(settingStateProvider.notifier).setBaseUrl(text);
      },
    );
  }
}

class SettingItemAppTheme extends HookConsumerWidget {
  const SettingItemAppTheme({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apptheme = ref.watch(settingStateProvider).valueOrNull?.appTheme ??
        ThemeMode.system;
    return ListTile(
      title: Text(AppIntl.of(context).settingThemeLabel),
      subtitle: Row(
        children: [
          RadioMenuButton(
            value: ThemeMode.system,
            groupValue: apptheme,
            onChanged: (v) {
              ref
                  .read(settingStateProvider.notifier)
                  .setAppTheme(ThemeMode.system);
            },
            child: Text(AppIntl.of(context).themeSystem),
          ),
          RadioMenuButton(
            value: ThemeMode.light,
            groupValue: apptheme,
            onChanged: (v) {
              ref
                  .read(settingStateProvider.notifier)
                  .setAppTheme(ThemeMode.light);
            },
            child: Text(AppIntl.of(context).themeLight),
          ),
          RadioMenuButton(
            value: ThemeMode.dark,
            groupValue: apptheme,
            onChanged: (v) {
              ref
                  .read(settingStateProvider.notifier)
                  .setAppTheme(ThemeMode.dark);
            },
            child: Text(AppIntl.of(context).themeDark),
          ),
        ],
      ),
    );
  }
}

class SettingItemLanguage extends HookConsumerWidget {
  const SettingItemLanguage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(settingStateProvider).valueOrNull?.locale;
    return ListTile(
      title: Text(AppIntl.of(context).settingsLanguageLabel),
      subtitle: Row(
          children: [
        Tuple2<Locale?, String>(null, AppIntl.of(context).lanSystem),
        Tuple2<Locale?, String>(const Locale("en"), AppIntl.of(context).lanEn),
        Tuple2<Locale?, String>(const Locale("zh"), AppIntl.of(context).lanZh),
      ]
              .map((e) => RadioMenuButton(
                    value: e.item1,
                    groupValue: locale,
                    onChanged: (v) {
                      ref.read(settingStateProvider.notifier).setLocale(v);
                    },
                    child: Text(e.item2),
                  ))
              .toList()),
    );
  }
}

Future<String?> showEditor(
  TextEditingController controller,
  WidgetRef ref,
  String title, {
  String? text,
  String? hint,
}) async {
  controller.text = text ?? '';
  return await showDialog<String?>(
    context: ref.context,
    builder: (context) => AlertDialog(
      actions: [
        // negitive button
        TextButton(
          child: Text(AppIntl.of(context).cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(AppIntl.of(context).ok),
          onPressed: () {
            final text = controller.text;
            controller.clear();
            Navigator.of(context).pop(text);
          },
        ),
      ],
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint),
      ),
    ),
  );
}
