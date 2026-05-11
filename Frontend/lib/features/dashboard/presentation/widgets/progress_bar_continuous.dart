import 'package:flutter/material.dart';

/// Barra de progreso horizontal continua. Usada en la tarjeta "Total animales activos".
class ProgressBarContinuous extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const ProgressBarContinuous({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor = color ?? cs.primary;
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            height: height,
            color: cs.outline.withValues(alpha: 0.25),
          ),
          FractionallySizedBox(
            widthFactor: clamped,
            child: Container(height: height, color: barColor),
          ),
        ],
      ),
    );
  }
}
