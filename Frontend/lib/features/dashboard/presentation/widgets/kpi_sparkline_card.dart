import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/dashboard_summary.dart';

/// Card KPI con número grande + delta badge + mini sparkline.
/// Estilo tipo dashboard de Stripe/Shopify.
class KpiSparklineCard extends StatelessWidget {
  final String label;
  final String value;
  final TrendSeries trend;
  final IconData icon;
  final Color? accentColor;

  const KpiSparklineCard({
    super.key,
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = accentColor ?? cs.primary;
    final deltaColor =
        trend.isPositive ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final deltaSign = trend.isPositive ? '↑' : '↓';
    final deltaPctStr = trend.deltaPct.abs().toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + label
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Value + delta
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (trend.values.length >= 2)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: deltaColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$deltaSign$deltaPctStr%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: deltaColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Sparkline
          SizedBox(
            height: 36,
            child: trend.values.length >= 2
                ? _Sparkline(trend: trend, color: color)
                : Center(
                    child: Text(
                      '—',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, end: 0, duration: 500.ms);
  }
}

class _Sparkline extends StatelessWidget {
  final TrendSeries trend;
  final Color color;
  const _Sparkline({required this.trend, required this.color});

  @override
  Widget build(BuildContext context) {
    final values = trend.values;
    final spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final hasWeeks = trend.weeks.length == values.length;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => color.withValues(alpha: 0.92),
            tooltipRoundedRadius: 8,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            getTooltipItems: (spots) => spots.map((spot) {
              final i = spot.x.toInt();
              final week = hasWeeks ? trend.weeks[i] : null;
              final label = week != null
                  ? '${_fmtDate(week)} · ${_fmtNum(spot.y)}'
                  : _fmtNum(spot.y);
              return LineTooltipItem(
                label,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              );
            }).toList(),
          ),
        ),
        clipData: const FlClipData.all(),
        minY: values.reduce((a, b) => a < b ? a : b) * 0.8,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, _, _) {
                // Solo mostrar dot en el último punto
                if (spot.x == spots.last.x) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: color,
                    strokeWidth: 0,
                  );
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  String _fmtNum(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}
