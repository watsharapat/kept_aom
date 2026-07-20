import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeViewModel extends _$ThemeViewModel {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  void toggleTheme() async {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
    _saveTheme();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state == ThemeMode.dark);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
