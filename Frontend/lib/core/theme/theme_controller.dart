import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador de tema global. Persiste la preferencia light/dark en
/// SharedPreferences y expone un ValueNotifier que app.dart escucha
/// para rebuildar MaterialApp con el ThemeMode correcto.
///
/// Mismo patrón que LocaleController.
class ThemeController extends ValueNotifier<ThemeMode> {
  static const _key = 'farmlink.themeMode';
  final SharedPreferences _prefs;

  ThemeController(this._prefs) : super(_load(_prefs));

  static ThemeMode _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }

  bool get isDark => value == ThemeMode.dark;

  void setTheme(ThemeMode mode) {
    value = mode;
    _prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void toggleTheme() {
    setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
