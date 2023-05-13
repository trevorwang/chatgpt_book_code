import 'package:share_plus/share_plus.dart';

Future shareFiles(List<String> paths) async {
  // 使用真机测试
  return Share.shareXFiles(paths.map((e) => XFile(e)).toList(),
      text: "ChatGPT");
}
