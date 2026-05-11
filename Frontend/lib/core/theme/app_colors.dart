import 'package:flutter/material.dart';

/// Tokens de color de FarmLink — Paleta Blanco + Azul Profundo.
///
/// Regla: NINGÚN otro archivo del proyecto puede declarar literales `Color(0xFF...)`.
/// Todo color debe consumirse desde aquí o vía `Theme.of(context).colorScheme`.
class AppColors {
  AppColors._();

  // ---------- Marca: azul ----------
  static const Color primary = Color(0xFF1E3A5F);        // azul oscuro profundo
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF3B82F6);    // azul brillante
  static const Color primarySoft = Color(0xFF60A5FA);     // azul suave
  static const Color primaryTint = Color(0x1A1E3A5F);    // primary ~10% alpha

  // ---------- Superficies ----------
  static const Color surfaceBg = Color(0xFFF8FAFC);       // gris-azulado claro
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color foreground = Color(0xFF0F172A);

  // ---------- Tipografía ----------
  static const Color textPrimary = Color(0xFF0F172A);      // slate-900
  static const Color textMuted = Color(0xFF64748B);        // slate-500
  static const Color textHint = Color(0xFF94A3B8);         // slate-400

  // ---------- Estados ----------
  static const Color destructive = Color(0xFFDC2626);
  static const Color destructiveSoft = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);

  // ---------- UI auxiliares ----------
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryForeground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSoft = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF8FAFC);
  static const Color trackBg = Color(0xFFE2E8F0);

  // Legacy aliases (widgets anteriores usan estos nombres)
  static const Color oliveTint = primaryTint;
  static const Color oliveLight = primaryLight;
  static const Color oliveDark = primary;

  // ---------- Modo oscuro ----------
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color foregroundDark = Color(0xFFF8FAFC);
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color primaryForegroundDark = Color(0xFFFFFFFF);
  static const Color secondaryDark = Color(0xFF1E293B);
  static const Color secondaryForegroundDark = Color(0xFFF8FAFC);
  static const Color mutedDark = Color(0xFF1E293B);
  static const Color mutedForegroundDark = Color(0xFF94A3B8);
  static const Color destructiveDark = Color(0xFFDC2626);
  static const Color borderDark = Color(0xFF334155);
  static const Color inputBackgroundDark = Color(0xFF1E293B);
}
