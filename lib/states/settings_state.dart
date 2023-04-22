import 'package:chatgpt/injection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    String? apiKey,
    String? httpProxy,
    String? baseUrl,
  }) = _Settings;

  static Future<Settings> load() async {
    final apiKey = await localStorage.getItem<String>(SettingKey.apiKey.name);
    final baseUrl = await localStorage.getItem<String>(SettingKey.baseUrl.name);
    final httpProxy =
        await localStorage.getItem<String>(SettingKey.httpProxy.name);

    return Settings(
      apiKey: apiKey,
      baseUrl: baseUrl,
      httpProxy: httpProxy,
    );
  }
}

@riverpod
class SettingState extends _$SettingState {
  @override
  FutureOr<Settings> build() async {
    return Settings.load();
  }

  Future<void> setApiKey(String? apiKey) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.apiKey.name, apiKey);
      final settings = state.valueOrNull ?? const Settings();
      chatgpt.loadConfig();
      return settings.copyWith(apiKey: apiKey);
    });
  }

  Future<void> setBaseUrl(String? baseUrl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.baseUrl.name, baseUrl);
      final settings = state.valueOrNull ?? const Settings();
      chatgpt.loadConfig();
      return settings.copyWith(baseUrl: baseUrl);
    });
  }

  Future<void> setHttpProxy(String? httpProxy) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.httpProxy.name, httpProxy);
      final settings = state.valueOrNull ?? const Settings();
      chatgpt.loadConfig();
      return settings.copyWith(httpProxy: httpProxy);
    });
  }
}

@freezed
class SettingItem with _$SettingItem {
  const factory SettingItem({
    required SettingKey key,
    required String title,
    String? subtitle,
    @Default(false) bool multiline,
    required String hint,
  }) = _SettingItem;
}

@riverpod
List<SettingItem> settingList(SettingListRef ref) {
  final settings = ref.watch(settingStateProvider).valueOrNull;

  return [
    SettingItem(
      key: SettingKey.apiKey,
      title: "API Key",
      subtitle: settings?.apiKey,
      hint: "Please input API Key",
    ),
    SettingItem(
        key: SettingKey.httpProxy,
        title: "HTTP Proxy",
        subtitle: settings?.httpProxy,
        hint: "Please input HTTP Proxy"),
    SettingItem(
        key: SettingKey.baseUrl,
        title: "Reverse proxy URL",
        subtitle: settings?.baseUrl,
        hint: "https://openai.proxy.dev/v1"),
  ];
}

enum SettingKey {
  apiKey,
  httpProxy,
  baseUrl,
}
