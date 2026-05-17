import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/widgets/section_header.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          SectionHeader(
            title: t.healthTitle,
            subtitle: t.healthSubtitle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _HubCard(
                  icon: PhosphorIcons.firstAidKit(PhosphorIconsStyle.fill),
                  title: t.healthRecords,
                  description: t.healthRecordsDescription,
                  onTap: () => context.push('/health/salud'),
                ),
                const SizedBox(height: 14),
                _HubCard(
                  icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                  title: t.reproduction,
                  description: t.reproductionDescription,
                  onTap: () => context.push('/health/reproduccion'),
                ),
                const SizedBox(height: 14),
                _HubCard(
                  icon: Icons.warning_rounded,
                  title: t.alertCenter,
                  description: t.alertCenterDescription,
                  onTap: () => context.push('/health/alertas'),
                ),
                const SizedBox(height: 14),
                _HubCard(
                  icon: PhosphorIcons.stethoscope(PhosphorIconsStyle.fill),
                  title: 'Veterinarios',
                  description: 'Contactos y agenda de visitas',
                  onTap: () => context.push('/health/veterinarios'),
                ),
                const SizedBox(height: 14),
                _HubCard(
                  icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                  title: 'Citas',
                  description: 'Programar y gestionar citas',
                  onTap: () => context.push('/health/citas'),
                ),
                const SizedBox(height: 14),
                _HubCard(
                  icon: PhosphorIcons.firstAid(PhosphorIconsStyle.fill),
                  title: 'Tratamientos',
                  description: 'Historial clínico de animales',
                  onTap: () => context.push('/health/tratamientos'),
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
                child: Icon(icon, color: cs.primary, size: 28),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
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