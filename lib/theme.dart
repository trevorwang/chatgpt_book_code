import 'package:flutter/material.dart';

const fontsFallback = [
  "Noto Sans CJK SC",
  "Droid Sans Fallback",
];
final lightThemeData = ThemeData(
  fontFamilyFallback: fontsFallback,
);

final darkThemeData = ThemeData(
  brightness: Brightness.dark,
  fontFamilyFallback: fontsFallback,
);

bool isDarkMode(BuildContext context) {
  final currentBrightness = Theme.of(context).brightness;
  return currentBrightness == Brightness.dark;
}
