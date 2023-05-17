import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../intl.dart';
import '../predefined.dart';
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
    final items = ref.watch(settingListProvider);
    final apptheme =
        ref.watch(settingStateProvider).valueOrNull?.appTheme ?? AppTheme.auto;
    final controller = useTextEditingController();

    return ListView.separated(
      itemBuilder: (context, index) {
        final item = items[index];

        if (index == 3) {
          return ListTile(
            title: Text(item.title),
            subtitle: Row(
              children: [
                RadioMenuButton(
                  value: AppTheme.auto,
                  groupValue: apptheme,
                  onChanged: (v) {
                    ref
                        .read(settingStateProvider.notifier)
                        .setAppTheme(AppTheme.auto);
                  },
                  child: Text(AppIntl.of(context).themeSystem),
                ),
                RadioMenuButton(
                  value: AppTheme.light,
                  groupValue: apptheme,
                  onChanged: (v) {
                    ref
                        .read(settingStateProvider.notifier)
                        .setAppTheme(AppTheme.light);
                  },
                  child: Text(AppIntl.of(context).themeLight),
                ),
                RadioMenuButton(
                  value: AppTheme.dark,
                  groupValue: apptheme,
                  onChanged: (v) {
                    ref
                        .read(settingStateProvider.notifier)
                        .setAppTheme(AppTheme.dark);
                  },
                  child: Text(AppIntl.of(context).themeDark),
                ),
              ],
            ),
          );
        }
        return ListTile(
          title: Text(item.title),
          subtitle:
              Text(item.subtitle ?? AppIntl.of(context).unkonwSettingLabel),
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
        title: Text(item.title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: item.hint),
        ),
      ),
    );
  }
}
