import 'package:localstorage/localstorage.dart';

class LocalStoreService {
  final localStorage = LocalStorage('chatgpt');

  Future<T?> getItem<T>(String key) async {
    await localStorage.ready;
    return localStorage.getItem(key) as T?;
  }

  Future<void> setItem(String key, dynamic value) async {
    return await localStorage.setItem(key, value);
  }
}
