import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../injection.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    String? apiKey,
    String? httpProxy,
    String? baseUrl,
    @Default(ThemeMode.system) ThemeMode appTheme,
    Locale? locale,
  }) = _Settings;

  static Future<Settings> load() async {
    final apiKey = await localStorage.getItem<String>(SettingKey.apiKey.name);
    final baseUrl = await localStorage.getItem<String>(SettingKey.baseUrl.name);
    final httpProxy =
        await localStorage.getItem<String>(SettingKey.httpProxy.name);
    final appTheme = await localStorage.getItem(SettingKey.appTheme.name) ??
        ThemeMode.system.index;
    final locale = await localStorage.getItem<String?>(SettingKey.locale.name);
    return Settings(
      apiKey: apiKey,
      baseUrl: baseUrl,
      httpProxy: httpProxy,
      appTheme: ThemeMode.values[appTheme],
      locale: locale == null ? null : Locale(locale),
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

  Future<void> setAppTheme(ThemeMode theme) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.appTheme.name, theme.index);
      final settings = state.valueOrNull ?? const Settings();
      chatgpt.loadConfig();
      return settings.copyWith(appTheme: theme);
    });
  }

  Future<void> setLocale(Locale? locale) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await localStorage.setItem(SettingKey.locale.name, locale?.languageCode);
      final settings = state.valueOrNull ?? const Settings();
      chatgpt.loadConfig();
      return settings.copyWith(locale: locale);
    });
  }
}

enum SettingKey {
  apiKey,
  httpProxy,
  baseUrl,
  appTheme,
  locale,
}
