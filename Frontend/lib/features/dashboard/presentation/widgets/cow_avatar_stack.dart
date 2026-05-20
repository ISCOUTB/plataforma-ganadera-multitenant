import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Stack de avatares de vacas (íconos SVG) con un chip "+N" al final.
///
/// Decisión del usuario: en lugar de imágenes raster usamos íconos SVG
/// vía Phosphor Icons (vector, sin assets externos).
class CowAvatarStack extends StatelessWidget {
  final int extraCount;
  final int avatars;
  final double size;

  const CowAvatarStack({
    super.key,
    this.avatars = 2,
    required this.extraCount,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = [
      cs.primary,
      cs.secondary,
      cs.primary,
    ];
    final overlap = size * 0.55;
    final stackWidth = size + (avatars - 1) * overlap + 12 + size * 1.05;

    return SizedBox(
      height: size,
      width: stackWidth,
      child: Stack(
        children: [
          for (int i = 0; i < avatars; i++)
            Positioned(
              left: i * overlap,
              child: _CowCircle(
                color: colors[i % colors.length],
                size: size,
              ),
            ),
          Positioned(
            left: avatars * overlap + 6,
            child: _CountChip(label: '+$extraCount', size: size),
          ),
        ],
      ),
    );
  }
}

class _CowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _CowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: cs.surface, width: 2),
      ),
      child: Center(
        child: PhosphorIcon(
          PhosphorIcons.cow(PhosphorIconsStyle.fill),
          color: cs.onPrimary,
          size: size * 0.62,
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final double size;
  const _CountChip({required this.label, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.outline.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
    );
  }
}
