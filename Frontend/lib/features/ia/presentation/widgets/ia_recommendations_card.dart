import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../fincas/presentation/bloc/fincas_list_bloc.dart';
import '../../domain/entities/recommendation.dart';
import '../bloc/recommendations_bloc.dart';
import '../bloc/recommendations_event.dart';
import '../bloc/recommendations_state.dart';

class IaRecommendationsCard extends StatelessWidget {
  const IaRecommendationsCard({super.key});

  void _loadRecommendations(BuildContext context) {
    final tenantId = context.read<AuthBloc>().state.user?.tenantId ?? '';
    final fincaId = context.read<FincasListBloc>().state.selectedFincaId ?? '';

    context.read<RecommendationsBloc>().add(
          GetRecommendationsEvent(
            tenantId: tenantId,
            fincaId: fincaId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Recomendaciones',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              BlocBuilder<RecommendationsBloc, RecommendationsState>(
                builder: (context, state) {
                  final isLoading = state is RecommendationsLoadingState;
                  return IconButton(
                    onPressed:
                        isLoading ? null : () => _loadRecommendations(context),
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    color: const Color(0xFF16A34A),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: BlocBuilder<RecommendationsBloc, RecommendationsState>(
              builder: (context, state) {
                if (state is RecommendationsLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is RecommendationsErrorState) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: cs.error,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _loadRecommendations(context),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is RecommendationsSuccessState &&
                    state.recommendations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca para obtener recomendaciones',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is RecommendationsSuccessState) {
                  return _RecommendationsList(
                    recommendations: state.recommendations,
                  );
                }

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para obtener recomendaciones',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
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

class _RecommendationsList extends StatelessWidget {
  final List<Recommendation> recommendations;
  const _RecommendationsList({required this.recommendations});

  IconData _categoryIcon(RecommendationCategory category) {
    return switch (category) {
      RecommendationCategory.alimentacion => Icons.restaurant_rounded,
      RecommendationCategory.salud => Icons.medical_services_rounded,
      RecommendationCategory.reproduccion => Icons.favorite_rounded,
      RecommendationCategory.finanzas => Icons.attach_money_rounded,
    };
  }

  Color _categoryColor(RecommendationCategory category) {
    return switch (category) {
      RecommendationCategory.alimentacion => const Color(0xFFF59E0B),
      RecommendationCategory.salud => const Color(0xFFEF4444),
      RecommendationCategory.reproduccion => const Color(0xFFEC4899),
      RecommendationCategory.finanzas => const Color(0xFF16A34A),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: recommendations.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final rec = recommendations[index];
        final color = _categoryColor(rec.category);
        final icon = _categoryIcon(rec.category);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    if (rec.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        rec.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
