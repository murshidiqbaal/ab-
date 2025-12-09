import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeManager extends ValueNotifier<ThemeMode> {
  ThemeManager() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _boxName = 'settingsBox';
  static const String _key = 'isDark';

  void _loadTheme() {
    final box = Hive.box(_boxName);
    final isDark = box.get(_key, defaultValue: false);
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final box = Hive.box(_boxName);
    box.put(_key, value == ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    value = mode;
    final box = Hive.box(_boxName);
    box.put(_key, value == ThemeMode.dark);
  }
}

final themeManager = ThemeManager();
