import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../fincas/presentation/bloc/fincas_list_bloc.dart';
import '../../domain/entities/prediction.dart';
import '../bloc/predictions_bloc.dart';
import '../bloc/predictions_event.dart';
import '../bloc/predictions_state.dart';

class IaPredictionsCard extends StatelessWidget {
  const IaPredictionsCard({super.key});

  void _loadPredictions(BuildContext context) {
    final tenantId = context.read<AuthBloc>().state.user?.tenantId ?? '';
    final fincaId = context.read<FincasListBloc>().state.selectedFincaId ?? '';

    final sampleValues = List<double>.generate(
      15,
      (i) => 200 + (i * 10) + (i % 3 == 0 ? 20 : -10),
    );

    context.read<PredictionsBloc>().add(
          GetPredictionsEvent(
            metric: 'weight',
            values: sampleValues,
            tenantId: tenantId,
            fincaId: fincaId,
            steps: 30,
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
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Color(0xFF3B82F6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Predicciones',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              BlocBuilder<PredictionsBloc, PredictionsState>(
                builder: (context, state) {
                  final isLoading = state is PredictionsLoadingState;
                  return IconButton(
                    onPressed: isLoading ? null : () => _loadPredictions(context),
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    color: const Color(0xFF3B82F6),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: BlocBuilder<PredictionsBloc, PredictionsState>(
              builder: (context, state) {
                if (state is PredictionsLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PredictionsErrorState) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, color: cs.error, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _loadPredictions(context),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PredictionsSuccessState && state.predictions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca para obtener predicciones',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PredictionsSuccessState) {
                  return _PredictionsList(predictions: state.predictions);
                }

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para obtener predicciones',
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

class _PredictionsList extends StatelessWidget {
  final List<Prediction> predictions;
  const _PredictionsList({required this.predictions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: predictions.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        final trendIcon = switch (prediction.trend) {
          TrendType.up => Icons.trending_up_rounded,
          TrendType.down => Icons.trending_down_rounded,
          TrendType.stable => Icons.trending_flat_rounded,
        };
        final trendColor = switch (prediction.trend) {
          TrendType.up => const Color(0xFF16A34A),
          TrendType.down => const Color(0xFFEF4444),
          TrendType.stable => const Color(0xFFF59E0B),
        };

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(trendIcon, color: trendColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prediction.type.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${(prediction.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: trendColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (prediction.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  prediction.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
