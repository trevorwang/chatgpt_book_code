import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../states/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const SettingsWindow(),
    );
  }
}

class SettingsWindow extends HookConsumerWidget {
  const SettingsWindow({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(settingListProvider);
    final settings = ref.watch(settingStateProvider).valueOrNull;
    final apptheme = settings?.appTheme ?? ThemeMode.system;
    final controller = useTextEditingController();

    return ListView.separated(
      itemBuilder: (context, index) {
        final item = items[index];
        if (SettingKey.locale == item.key) {
          return ListTile(
            title: Text(item.title),
            subtitle: Row(
              children: [
                RadioMenuButton(
                  value: null,
                  groupValue: settings?.locale,
                  onChanged: (v) {
                    ref.read(settingStateProvider.notifier).setLocale(v);
                  },
                  child:
                      Text(AppLocalizations.of(context)!.settingsLabelSystem),
                ),
                RadioMenuButton(
                  value: const Locale('en'),
                  groupValue: settings?.locale,
                  onChanged: (v) {
                    ref.read(settingStateProvider.notifier).setLocale(v);
                  },
                  child: const Text('English'),
                ),
                RadioMenuButton(
                  value: const Locale('zh'),
                  groupValue: settings?.locale,
                  onChanged: (v) {
                    ref.read(settingStateProvider.notifier).setLocale(v);
                  },
                  child: const Text('中文'),
                ),
              ],
            ),
          );
        } else if (index == 3) {
          return ListTile(
            title: Text(item.title),
            subtitle: Row(
              children: [
                RadioMenuButton(
                  value: ThemeMode.system,
                  groupValue: apptheme,
                  onChanged: (v) {
                    ref
                        .read(settingStateProvider.notifier)
                        .setThemeMode(ThemeMode.system);
                  },
                  child: const Text('System'),
                ),
                RadioMenuButton(
                  value: ThemeMode.light,
                  groupValue: apptheme,
                  onChanged: (v) {
                    ref
                        .read(settingStateProvider.notifier)
                        .setThemeMode(ThemeMode.light);
                  },
                  child: const Text('Light'),
                ),
                RadioMenuButton(
                  value: ThemeMode.dark,
                  groupValue: apptheme,
                  onChanged: (v) {
                    ref
                        .read(settingStateProvider.notifier)
                        .setThemeMode(ThemeMode.dark);
                  },
                  child: const Text('Dark'),
                ),
              ],
            ),
          );
        }
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.subtitle ?? 'Unknown'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            final text = await showEditor(controller, item, ref);
            if (text == null) return;
            switch (item.key) {
              case SettingKey.apiKey:
                ref.read(settingStateProvider.notifier).setApiKey(text);
                break;
              case SettingKey.httpProxy:
                ref.read(settingStateProvider.notifier).setHttpProxy(text);
                break;
              case SettingKey.baseUrl:
                ref.read(settingStateProvider.notifier).setBaseUrl(text);
                break;
              default:
                break;
            }
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: items.length,
    );
  }

  Future<String?> showEditor(
      TextEditingController controller, SettingItem item, WidgetRef ref) async {
    controller.text = item.subtitle ?? '';
    return await showDialog<String?>(
      context: ref.context,
      builder: (context) => AlertDialog(
        actions: [
          // negitive button
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              final text = controller.text;
              controller.clear();
              Navigator.of(context).pop(text);
            },
          ),
        ],
        title: Text(item.title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: item.hint),
        ),
      ),
    );
  }
}
