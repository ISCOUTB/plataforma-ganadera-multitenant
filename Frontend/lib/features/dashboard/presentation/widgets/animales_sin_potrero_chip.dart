import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/routing/route_paths.dart';

/// Banner ámbar que avisa cuántos animales están sin potrero asignado.
/// Solo renderiza si `count > 0`. Tap → navega al inventario.
class AnimalesSinPotreroChip extends StatelessWidget {
  final int count;
  const AnimalesSinPotreroChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final amber = const Color(0xFFF59E0B);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF3B2A06) : const Color(0xFFFEF3C7);

    return GestureDetector(
      onTap: () => context.push(RoutePaths.inventory),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: amber.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.warning(PhosphorIconsStyle.fill),
              color: amber,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count ${count == 1 ? 'animal' : 'animales'} sin potrero asignado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: amber,
              size: 22,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
