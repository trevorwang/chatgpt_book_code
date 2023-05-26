import 'package:flutter/material.dart';

import 'colors.dart';

// linux fallback fonts
const fontsFallback = [
  "Noto Sans CJK SC",
  "Droid Sans Fallback",
];
final lightThemeData = ThemeData(
  fontFamilyFallback: fontsFallback,
  scaffoldBackgroundColor: bgLight,
);

final darkThemeData = ThemeData(
  brightness: Brightness.dark,
  fontFamilyFallback: fontsFallback,
);

bool isDarkMode(BuildContext context) {
  final currentBrightness = Theme.of(context).brightness;
  return currentBrightness == Brightness.dark;
}
