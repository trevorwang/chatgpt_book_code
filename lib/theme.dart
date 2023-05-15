import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'predefined.dart';

final dartThemeData = ThemeData.dark();

final lightThemeData = ThemeData();

bool isDarkMode(BuildContext context) {
  final currentBrightness = Theme.of(context).brightness;
  return currentBrightness == Brightness.dark;
}

Tuple2<ThemeData?, ThemeData?> getThemeData(AppTheme? theme) {
  if (theme == AppTheme.light) {
    return Tuple2(lightThemeData, null);
  } else if (theme == AppTheme.dark) {
    return Tuple2(dartThemeData, null);
  } else {
    return Tuple2(lightThemeData, dartThemeData);
  }
}
