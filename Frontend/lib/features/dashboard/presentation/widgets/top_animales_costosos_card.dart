import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/dashboard_inteligencia.dart';

/// Lista los 5 animales con mayor costo acumulado (salud + alimentación).
/// Ayuda al ganadero a detectar dónde se está yendo el presupuesto.
class TopAnimalesCostososCard extends StatelessWidget {
  final List<AnimalCostoso> animales;
  const TopAnimalesCostososCard({super.key, required this.animales});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
                PhosphorIcons.coins(PhosphorIconsStyle.fill),
                color: cs.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Animales con mayor costo',
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
            'Top 5 por costo acumulado (salud + alimentación)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          if (animales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Aún no hay costos registrados',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...animales.asMap().entries.map((entry) {
              final i = entry.key;
              final a = entry.value;
              final maxCost = animales
                  .map((e) => e.costoTotal)
                  .reduce((a, b) => a > b ? a : b)
                  .clamp(1.0, double.infinity);
              return _AnimalRow(animal: a, index: i, maxCost: maxCost);
            }),
        ],
      ),
    );
  }
}

class _AnimalRow extends StatelessWidget {
  final AnimalCostoso animal;
  final int index;
  final double maxCost;
  const _AnimalRow({
    required this.animal,
    required this.index,
    required this.maxCost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pct = (animal.costoTotal / maxCost).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '#${animal.numeroIdentificacion}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                _fmtMoney(animal.costoTotal),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: Duration(milliseconds: 600 + index * 100),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: cs.outline.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Salud ${_fmtMoney(animal.costoSalud)} · Alimentación ${_fmtMoney(animal.costoAlimentacion)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 80))
        .slideX(begin: -0.05, end: 0);
  }

  String _fmtMoney(double v) {
    if (v.abs() >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(0)}';
  }
}
