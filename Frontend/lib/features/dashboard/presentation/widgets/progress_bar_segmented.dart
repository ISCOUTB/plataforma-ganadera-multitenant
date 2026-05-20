import 'package:flutter/material.dart';

/// Barra de progreso segmentada (5 bloques). Usada en la tarjeta "Alertas de salud".
class ProgressBarSegmented extends StatelessWidget {
  final int filledCount;
  final int totalSegments;
  final Color? color;
  final double height;
  final double gap;

  const ProgressBarSegmented({
    super.key,
    required this.filledCount,
    this.totalSegments = 5,
    this.color,
    this.height = 8,
    this.gap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor = color ?? cs.error;
    final clamped = filledCount.clamp(0, totalSegments);
    return Row(
      children: List.generate(totalSegments, (i) {
        final isFilled = i < clamped;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == totalSegments - 1 ? 0 : gap),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: isFilled ? barColor : cs.outline.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }),
    );
  }
}
