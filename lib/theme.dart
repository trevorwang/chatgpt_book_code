import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'predefined.dart';

const fontsFallback = [
  "Noto Sans CJK SC",
  "Droid Sans Fallback",
];
final lightThemeData = ThemeData(
  fontFamilyFallback: fontsFallback,
);

final darkThemeData = lightThemeData.copyWith(
  brightness: Brightness.dark,
);

bool isDarkMode(BuildContext context) {
  final currentBrightness = Theme.of(context).brightness;
  return currentBrightness == Brightness.dark;
}

Tuple2<ThemeData?, ThemeData?> getThemeData(AppTheme? theme) {
  if (theme == AppTheme.light) {
    return Tuple2(lightThemeData, null);
  } else if (theme == AppTheme.dark) {
    return Tuple2(darkThemeData, null);
  } else {
    return Tuple2(lightThemeData, darkThemeData);
  }
}
