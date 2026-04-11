// lib/backend/theme_provider.dart
//
// Persists dark-mode preference via SharedPreferences.
// Consumed in main.dart to drive themeMode.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

const _kDarkModeKey = 'pref_dark_mode';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system; // default until prefs load

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_kDarkModeKey);
    if (stored != null) {
      state = stored ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, !isDark);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
