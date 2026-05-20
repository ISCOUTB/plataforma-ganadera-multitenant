import 'dart:math' as math;
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/dashboard_summary.dart';

/// Card de ocupación del terreno con gauge semicircular animado.
class OccupancyCard extends StatelessWidget {
  final OccupancyData data;

  const OccupancyCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pct = data.usedPct;
    final Color gaugeColor = pct >= 90
        ? cs.error
        : pct >= 70
            ? cs.tertiary
            : cs.primary;

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
      child: Row(
        children: [
          // Gauge animado
          SizedBox(
            width: 100,
            height: 100,
            child: _AnimatedGauge(
              percentage: pct / 100,
              color: gaugeColor,
              bgColor: const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(width: 24),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).landOccupancy,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: gaugeColor,
                      height: 1,
                    ),
                    children: [
                      TextSpan(text: '${data.usedHectares}'),
                      TextSpan(
                        text: ' ha',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'de ${data.totalHectares} ha totales',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pct >= 90
                      ? S.of(context).saturatedLand
                      : pct >= 70
                          ? S.of(context).highUsage
                          : S.of(context).availableCapacity,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: gaugeColor,
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

/// Gauge semicircular pintado con CustomPainter y animado.
class _AnimatedGauge extends StatelessWidget {
  final double percentage;
  final Color color;
  final Color bgColor;

  const _AnimatedGauge({
    required this.percentage,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          painter: _GaugePainter(
            progress: value,
            color: color,
            bgColor: bgColor,
          ),
          child: Center(
            child: Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const startAngle = math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}
