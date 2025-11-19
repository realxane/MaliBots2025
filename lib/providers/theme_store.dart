import 'package:flutter/material.dart';

class ThemeStore extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light; // par défaut
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle(bool value) {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
} 