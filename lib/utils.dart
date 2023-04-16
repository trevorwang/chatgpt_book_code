import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

bool isDesktop() {
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

void initWindow() {
  if (isDesktop()) {
    doWhenWindowReady(() {
      const initialSize = Size(800, 600);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}
