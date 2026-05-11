import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/dashboard_summary.dart';
import 'dashboard_empty_state.dart';

/// Card de la UI Bento que renderiza `List<CriticalAlert>`. Si la lista
/// viene vacía del backend muestra un [DashboardEmptyState] invitando
/// al usuario a registrar su primer evento de salud.
class CriticalAlertsCard extends StatelessWidget {
  final List<CriticalAlert> alerts;

  /// Callback opcional para el CTA del empty state — la UI del shell lo
  /// conecta con el flujo de creación de salud (Fase C).
  final VoidCallback? onCreateHealthRecord;

  const CriticalAlertsCard({
    super.key,
    required this.alerts,
    this.onCreateHealthRecord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).criticalAlerts,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.warning_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
              ],
            ),
          ),
          // Contenido: lista o empty state
          if (alerts.isEmpty)
            DashboardEmptyState(
              icon: PhosphorIcons.firstAidKit(PhosphorIconsStyle.duotone),
              title: S.of(context).allGood,
              message: S.of(context).noAlertsMessage,
              actionLabel: S.of(context).addMedicalRecord,
              onPressed: onCreateHealthRecord,
              compact: true,
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
              child: Column(
                children: [
                  for (final alert in alerts.take(5))
                    _AlertRow(alert: alert),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final CriticalAlert alert;
  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isHigh = alert.urgency == AlertUrgency.high;
    final urgencyColor = isHigh ? colorScheme.error : colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: urgencyColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.animalId,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isHigh)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                S.of(context).urgent,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.error,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
