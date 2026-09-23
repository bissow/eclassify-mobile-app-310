import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';
import 'package:flutter/material.dart';

class ThemeStorage {
  ThemeStorage._();

  static ThemeMode getCurrentTheme() {
    // Read untyped: a non-String value must fall through to light rather
    // than throw, matching the pre-split behaviour.
    final current = HiveStorage.read<dynamic>(
      HiveKeys.themeBox,
      HiveKeys.currentTheme,
    );
    return current == "dark" ? ThemeMode.dark : ThemeMode.light;
  }

  static void setCurrentTheme(ThemeMode theme) {
    final newTheme = theme == ThemeMode.light ? "light" : "dark";
    HiveStorage.write(HiveKeys.themeBox, HiveKeys.currentTheme, newTheme);
  }
}
