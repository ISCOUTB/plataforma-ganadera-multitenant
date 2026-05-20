import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Donut chart macho/hembra con animación de escala.
class GenderSplitCard extends StatelessWidget {
  final GenderSplitData data;
  const GenderSplitCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maleColor = cs.primary;
    final femaleColor = const Color(0xFFEC4899); // rosa vivo
    final otherColor = cs.outline;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            S.of(context).gender,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: data.total > 0
                    ? PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 28,
                          startDegreeOffset: -90,
                          sections: [
                            if (data.machos > 0)
                              PieChartSectionData(
                                value: data.machos.toDouble(),
                                color: maleColor,
                                showTitle: false,
                                radius: 16,
                              ),
                            if (data.hembras > 0)
                              PieChartSectionData(
                                value: data.hembras.toDouble(),
                                color: femaleColor,
                                showTitle: false,
                                radius: 16,
                              ),
                            if (data.otros > 0)
                              PieChartSectionData(
                                value: data.otros.toDouble(),
                                color: otherColor,
                                showTitle: false,
                                radius: 16,
                              ),
                          ],
                        ),
                      )
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(
                        color: maleColor,
                        label: S.of(context).maleFilter,
                        value: '${data.machos}'),
                    const SizedBox(height: 10),
                    _LegendRow(
                        color: femaleColor,
                        label: S.of(context).femaleFilter,
                        value: '${data.hembras}'),
                    if (data.otros > 0) ...[
                      const SizedBox(height: 10),
                      _LegendRow(
                          color: otherColor,
                          label: 'Otros',
                          value: '${data.otros}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendRow(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            )),
      ],
    );
  }
}
