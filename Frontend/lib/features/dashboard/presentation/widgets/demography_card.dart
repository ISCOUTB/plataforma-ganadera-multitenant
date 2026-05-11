import 'package:fl_chart/fl_chart.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/dashboard_summary.dart';

/// Card demográfica del Bento con donut chart animado.
/// Muestra el desglose del hato: producción / crecimiento / secas.
class DemographyCard extends StatelessWidget {
  final DemographyData data;

  const DemographyCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).demography,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  S.of(context).activeAnimals(data.total),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 120,
                height: 120,
                child: data.total > 0
                    ? PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 36,
                          startDegreeOffset: -90,
                          sections: _buildSections(cs),
                        ),
                      )
                        .animate()
                        .scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                    : Center(
                        child: Text(
                          '—',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: cs.outline,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 24),
              // Leyenda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: cs.primary,
                      label: S.of(context).production,
                      value: '${data.produccionPct}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: cs.secondary,
                      label: S.of(context).growth,
                      value: '${data.crecimientoPct}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: cs.tertiary,
                      label: S.of(context).dry,
                      value: '${data.secasPct}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(ColorScheme cs) {
    final total = data.produccionPct + data.crecimientoPct + data.secasPct;
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: cs.outline.withValues(alpha: 0.2),
          showTitle: false,
          radius: 18,
        ),
      ];
    }
    return [
      if (data.produccionPct > 0)
        PieChartSectionData(
          value: data.produccionPct.toDouble(),
          color: cs.primary,
          showTitle: false,
          radius: 18,
        ),
      if (data.crecimientoPct > 0)
        PieChartSectionData(
          value: data.crecimientoPct.toDouble(),
          color: cs.secondary,
          showTitle: false,
          radius: 18,
        ),
      if (data.secasPct > 0)
        PieChartSectionData(
          value: data.secasPct.toDouble(),
          color: cs.tertiary,
          showTitle: false,
          radius: 18,
        ),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
