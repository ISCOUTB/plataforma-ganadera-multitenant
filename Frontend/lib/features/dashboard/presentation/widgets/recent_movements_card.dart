import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/dashboard_summary.dart';
import 'dashboard_empty_state.dart';

/// Card de la UI Bento que renderiza `List<RecentMovement>`. Si la lista
/// viene vacía del backend muestra un [DashboardEmptyState] invitando
/// al usuario a registrar su primer movimiento entre potreros.
class RecentMovementsCard extends StatelessWidget {
  final List<RecentMovement> movements;

  /// Callback opcional para el CTA del empty state — el shell lo
  /// conecta con el flujo de creación de movimientos (Fase D).
  final VoidCallback? onCreateMovement;

  const RecentMovementsCard({
    super.key,
    required this.movements,
    this.onCreateMovement,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).recentMovements,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.swap_horiz_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ],
            ),
          ),
          if (movements.isEmpty)
            DashboardEmptyState(
              icon: PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.duotone),
              title: S.of(context).noMovementsYet,
              message: S.of(context).noMovementsMessage,
              actionLabel: S.of(context).registerMovement,
              onPressed: onCreateMovement,
              compact: true,
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
              child: Column(
                children: [
                  for (final m in movements.take(5)) _MovementRow(movement: m),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  final RecentMovement movement;
  const _MovementRow({required this.movement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.swap_horiz_rounded,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${movement.origin} → ${movement.destination}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  movement.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
