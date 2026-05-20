import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/dashboard_inteligencia.dart';

/// KPI grande con la ganancia neta de las ventas registradas
/// (`total_ventas - costos_vendidos`). Verde si ≥ 0, rojo si < 0.
class GananciaCard extends StatelessWidget {
  final EstimacionGanancia data;
  const GananciaCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isPositive = data.gananciaNeta >= 0;
    final accent =
        isPositive ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final hasSales = data.animalesVendidos > 0;

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
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Estimación de ganancia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ventas - costos asociados al hato vendido',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          if (!hasSales)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Aún no hay ventas registradas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else ...[
            Text(
              _fmtMoney(data.gananciaNeta),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: accent,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Ventas',
                    value: _fmtMoney(data.totalVentas),
                    color: const Color(0xFF16A34A),
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Costos',
                    value: _fmtMoney(data.costosVendidos),
                    color: const Color(0xFFEF4444),
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Animales',
                    value: '${data.animalesVendidos}',
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.05, end: 0);
  }

  String _fmtMoney(double v) {
    final sign = v < 0 ? '-' : '';
    final abs = v.abs();
    if (abs >= 1000000) return '$sign\$${(abs / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '$sign\$${(abs / 1000).toStringAsFixed(1)}K';
    return '$sign\$${abs.toStringAsFixed(0)}';
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
