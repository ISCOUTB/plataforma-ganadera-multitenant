import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/dashboard_summary.dart';

/// Grid visual interactivo de potreros — "Mapa de la finca".
///
/// Cada potrero es una tarjeta coloreada por ocupación:
///   0–40%  → verde (libre)
///   41–70% → amarillo (medio)
///   71–90% → naranja (alto)
///   91%+   → rojo (lleno)
///
/// El tamaño de cada tarjeta es proporcional al área del potrero.
/// Tap → navega al detalle del potrero.
class FarmMapCard extends StatelessWidget {
  final List<PotreroRankData> potreros;
  const FarmMapCard({super.key, required this.potreros});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
                color: cs.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mapa de la finca',
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
                  '${potreros.length} potreros',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ocupación por zona — toca para ver detalle',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          if (potreros.isEmpty)
            _EmptyMap()
          else
            _PotrerosGrid(potreros: potreros),
          const SizedBox(height: 12),
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF16A34A), label: 'Libre'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFEAB308), label: 'Medio'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFF97316), label: 'Alto'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFEF4444), label: 'Lleno'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PotrerosGrid extends StatelessWidget {
  final List<PotreroRankData> potreros;
  const _PotrerosGrid({required this.potreros});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 400;
        final crossCount = isWide ? 3 : 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: potreros.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            // Tamaño proporcional al área (min 1, normalizado)
            final maxArea = potreros
                .map((e) => e.area)
                .reduce((a, b) => a > b ? a : b)
                .clamp(1.0, double.infinity);
            final sizeFactor = (p.area / maxArea).clamp(0.6, 1.0);
            final baseWidth =
                (constraints.maxWidth - (crossCount - 1) * 10) / crossCount;
            final width = baseWidth * sizeFactor;

            return SizedBox(
              width: width,
              child: _PotreroTile(potrero: p, index: i),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PotreroTile extends StatefulWidget {
  final PotreroRankData potrero;
  final int index;
  const _PotreroTile({required this.potrero, required this.index});

  @override
  State<_PotreroTile> createState() => _PotreroTileState();
}

class _PotreroTileState extends State<_PotreroTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final p = widget.potrero;
    final pct = p.pct;
    final estadoLower = p.estado?.toLowerCase();
    final occupancyColor =
        _colorForEstado(estadoLower) ?? _colorForPct(pct);
    final bgColor =
        _bgForEstado(estadoLower, cs.brightness) ?? _bgForPct(pct, cs.brightness);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push('/inventory/potreros/${p.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? occupancyColor
                  : occupancyColor.withValues(alpha: 0.3),
              width: _hovered ? 2 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: occupancyColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono + nombre
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: occupancyColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.grass_rounded,
                      color: occupancyColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Número grande
              RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: occupancyColor,
                    height: 1,
                  ),
                  children: [
                    TextSpan(text: '${p.ocupacion}'),
                    TextSpan(
                      text: '/${p.capacidad}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: pct.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: occupancyColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(occupancyColor),
                ),
              ),
              const SizedBox(height: 6),
              // Área
              if (p.area > 0)
                Text(
                  '${p.area.toStringAsFixed(1)} ha',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: widget.index * 80),
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: Duration(milliseconds: widget.index * 80),
          curve: Curves.easeOutBack,
        );
  }

  Color _colorForPct(double pct) {
    if (pct >= 0.91) return const Color(0xFFEF4444);
    if (pct >= 0.71) return const Color(0xFFF97316);
    if (pct >= 0.41) return const Color(0xFFEAB308);
    return const Color(0xFF16A34A);
  }

  Color _bgForPct(double pct, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    if (pct >= 0.91) {
      return isDark ? const Color(0xFF3B1111) : const Color(0xFFFEE2E2);
    }
    if (pct >= 0.71) {
      return isDark ? const Color(0xFF3B2006) : const Color(0xFFFFEDD5);
    }
    if (pct >= 0.41) {
      return isDark ? const Color(0xFF3B3006) : const Color(0xFFFEF9C3);
    }
    return isDark ? const Color(0xFF0A2E14) : const Color(0xFFDCFCE7);
  }

  Color? _colorForEstado(String? estado) {
    switch (estado) {
      case 'inactivo':
      case 'inactiva':
        return const Color(0xFF6B7280);
      case 'mantenimiento':
        return const Color(0xFFF59E0B);
      default:
        return null;
    }
  }

  Color? _bgForEstado(String? estado, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (estado) {
      case 'inactivo':
      case 'inactiva':
        return isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
      case 'mantenimiento':
        return isDark ? const Color(0xFF3B2A06) : const Color(0xFFFEF3C7);
      default:
        return null;
    }
  }
}

class _EmptyMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            PhosphorIcon(
              PhosphorIcons.mapTrifold(PhosphorIconsStyle.duotone),
              color: cs.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Sin potreros registrados',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
