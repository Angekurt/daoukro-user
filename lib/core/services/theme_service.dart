import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'daoukro_theme_mode';

  static Future<ThemeMode> getSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_key) ?? 'system';
    switch (val) {
      case 'light': return ThemeMode.light;
      case 'dark':  return ThemeMode.dark;
      default:      return ThemeMode.system;
    }
  }

  static Future<void> saveMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:  await prefs.setString(_key, 'light'); break;
      case ThemeMode.dark:   await prefs.setString(_key, 'dark');  break;
      default:               await prefs.setString(_key, 'system');
    }
  }
}
