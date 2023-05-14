import 'package:flutter/material.dart';

bool isDarkMode(BuildContext context) {
  final currentBrightness = Theme.of(context).brightness;
  return currentBrightness == Brightness.dark;
}
