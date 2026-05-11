import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

/// Tarjeta blanca reutilizable del Dashboard.
///
/// Composición:
/// - Fila superior: [title] (texto pequeño en mayúsculas) + [trailingIcon].
/// - Valor principal grande [mainValue] + valor lateral opcional [sideValue].
/// - Visual inferior libre [bottomVisual] (barra, avatares, etc.).
class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final Widget trailingIcon;
  final Widget mainValue;
  final Widget? sideValue;
  final Widget bottomVisual;

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.trailingIcon,
    required this.mainValue,
    this.sideValue,
    required this.bottomVisual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.cardTitle,
                ),
              ),
              const SizedBox(width: 12),
              trailingIcon,
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              mainValue,
              if (sideValue != null) ...[
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: sideValue!,
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          bottomVisual,
        ],
      ),
    );
  }
}
