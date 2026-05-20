import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/widgets/section_header.dart';

/// Hub del módulo de gestión económica y operativa:
/// Finanzas, Alimentos y Movimientos entre potreros.
class MoneyPage extends StatelessWidget {
  const MoneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          SectionHeader(
            title: t.operationsTitle,
            subtitle: t.operationsSubtitle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _HubCard(
                  icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
                  title: t.finances,
                  description: t.financesDescription,
                  onTap: () => context.push('/money/finanzas'),
                ),
                const SizedBox(height: 14),
                _HubCard(
                  icon: PhosphorIcons.plant(PhosphorIconsStyle.fill),
                  title: t.food,
                  description: t.foodDescription,
                  onTap: () => context.push('/money/alimentos'),
                ),
                const SizedBox(height: 14),
                _HubCard(
                  icon: PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill),
                  title: t.movements,
                  description: t.movementsDescription,
                  onTap: () => context.push('/money/movimientos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: PhosphorIcon(icon, color: cs.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
