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
}

@riverpod
class SettingState extends _$SettingState {
  @override
  FutureOr<Settings> build() async {
    return Settings(
      apiKey: localStorage.getItem(SettingKey.apiKey.name) as String?,
      baseUrl: localStorage.getItem(SettingKey.baseUrl.name) as String?,
      httpProxy: localStorage.getItem(SettingKey.httpProxy.name) as String?,
    );
  }

  Future<void> setApiKey(String? apiKey) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.apiKey.name, apiKey);
      final settings = state.valueOrNull ?? const Settings();
      return settings.copyWith(apiKey: apiKey);
    });
  }

  Future<void> setBaseUrl(String? baseUrl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.baseUrl.name, baseUrl);
      final settings = state.valueOrNull ?? const Settings();
      return settings.copyWith(baseUrl: baseUrl);
    });
  }

  Future<void> setHttpProxy(String? httpProxy) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.httpProxy.name, httpProxy);
      final settings = state.valueOrNull ?? const Settings();
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
