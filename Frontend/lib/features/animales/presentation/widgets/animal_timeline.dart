import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Timeline cronológico de eventos de un animal.
/// Renderiza una línea vertical con puntos coloreados por tipo.
class AnimalTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const AnimalTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline_rounded, size: 48, color: cs.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                'Sin eventos registrados',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'HISTORIAL',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        ...events.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final isLast = i == events.length - 1;
          return _TimelineItem(
            event: e,
            isLast: isLast,
            index: i,
          );
        }),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isLast;
  final int index;

  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final type = event['type'] as String? ?? '';
    final description = event['description'] as String? ?? '';
    final dateStr = event['date'] as String? ?? '';
    final color = _colorForType(type, cs);
    final icon = _iconForType(type);

    String formattedDate = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      formattedDate = DateFormat.yMMMd('es').format(dt);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line + dot
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 14),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: cs.outline.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _labelForType(type),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: index * 60),
        )
        .slideX(begin: -0.05, end: 0);
  }

  Color _colorForType(String type, ColorScheme cs) => switch (type) {
        'salud' => const Color(0xFF3B82F6),
        'movimiento' => const Color(0xFF16A34A),
        'finanza' => const Color(0xFFF59E0B),
        _ => cs.primary,
      };

  IconData _iconForType(String type) => switch (type) {
        'salud' => Icons.vaccines_rounded,
        'movimiento' => Icons.swap_horiz_rounded,
        'finanza' => Icons.attach_money_rounded,
        _ => Icons.circle,
      };

  String _labelForType(String type) => switch (type) {
        'salud' => 'SALUD',
        'movimiento' => 'TRASLADO',
        'finanza' => 'FINANZA',
        _ => type.toUpperCase(),
      };
}
