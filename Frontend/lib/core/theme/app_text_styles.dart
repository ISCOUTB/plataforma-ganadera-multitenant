import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos tipográficos reutilizables.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle greeting = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.6,
  );

  static const TextStyle bigNumber = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static const TextStyle bigNumberDanger = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.destructive,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static const TextStyle sideValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle sideValueDanger = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.destructive,
  );

  static const TextStyle sideValueMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    color: AppColors.textMuted,
  );
}
