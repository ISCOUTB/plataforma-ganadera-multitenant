import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader reutilizable. Reemplaza el spinner genérico con
/// placeholders que "brillan" mientras los datos cargan. El efecto shimmer
/// da la percepción de que algo está a punto de aparecer — mucho más
/// profesional que un CircularProgressIndicator.
class AppSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.outline.withValues(alpha: 0.15),
      highlightColor: cs.outline.withValues(alpha: 0.05),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton que replica la forma de una card de listado típica.
class AppCardSkeleton extends StatelessWidget {
  const AppCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.outline.withValues(alpha: 0.15),
      highlightColor: cs.outline.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.outline,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 90,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton que replica la forma del dashboard Bento (4 cards).
class AppDashboardSkeleton extends StatelessWidget {
  const AppDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(height: 28, width: 220),
          const SizedBox(height: 20),
          const AppSkeleton(height: 180),
          const SizedBox(height: 16),
          const AppSkeleton(height: 140),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: AppSkeleton(height: 120)),
              SizedBox(width: 14),
              Expanded(child: AppSkeleton(height: 120)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton list — N cards simuladas apiladas.
class AppListSkeleton extends StatelessWidget {
  final int count;
  const AppListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const AppCardSkeleton(),
    );
  }
}
