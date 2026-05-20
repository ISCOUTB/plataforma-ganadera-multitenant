import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador de idioma global. Persiste la preferencia en
/// SharedPreferences y expone un ValueNotifier que app.dart escucha
/// para rebuildar MaterialApp con el locale correcto.
class LocaleController extends ValueNotifier<Locale> {
  static const _key = 'farmlink.locale';
  final SharedPreferences _prefs;

  LocaleController(this._prefs) : super(_load(_prefs));

  static Locale _load(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    if (code == 'en') return const Locale('en');
    return const Locale('es');
  }

  void setLocale(Locale locale) {
    value = locale;
    _prefs.setString(_key, locale.languageCode);
  }

  void toggleLocale() {
    if (value.languageCode == 'es') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('es'));
    }
  }

  String get currentLabel =>
      value.languageCode == 'es' ? 'Español' : 'English';
}
