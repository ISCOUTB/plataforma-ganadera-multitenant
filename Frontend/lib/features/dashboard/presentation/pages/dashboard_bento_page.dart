import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../domain/entities/dashboard_inteligencia.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../fincas/presentation/bloc/fincas_list_bloc.dart';
import '../bloc/dashboard_inteligencia_bloc.dart';
import '../bloc/dashboard_summary_bloc.dart';
import '../widgets/animales_sin_potrero_chip.dart';
import '../widgets/critical_alerts_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/export_pdf_button.dart';
import '../widgets/demography_card.dart';
import '../widgets/farm_map_card.dart';
import '../widgets/finances_bar_card.dart';
import '../widgets/ganancia_card.dart';
import '../widgets/gender_split_card.dart';
import '../widgets/kpi_sparkline_card.dart';
import '../widgets/occupancy_card.dart';
import '../widgets/recent_movements_card.dart';
import '../widgets/top_animales_costosos_card.dart';
import '../widgets/top_potreros_card.dart';
import '../../../ia/presentation/widgets/ia_predictions_card.dart';
import '../../../ia/presentation/widgets/ia_recommendations_card.dart';

class DashboardBentoPage extends StatelessWidget {
  const DashboardBentoPage({super.key});

  /// El `DashboardSummaryBloc` ahora vive en `HomeShell` para que el
  /// `BlocListener<FincasListBloc>` del shell pueda escribirle cuando
  /// el usuario rota la finca activa. Esta página sólo lo consume.
  @override
  Widget build(BuildContext context) => const _DashboardBentoView();
}

class _DashboardBentoView extends StatelessWidget {
  const _DashboardBentoView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: BlocBuilder<DashboardSummaryBloc, DashboardSummaryState>(
        builder: (context, state) {
          if (state.data == null) {
            if (state.status == DashboardSummaryStatus.error &&
                state.failure != null) {
              return AppErrorView(
                failure: state.failure!,
                onRetry: () {
                  final tenantId =
                      context.read<AuthBloc>().state.user?.tenantId ?? '';
                  final fincaId =
                      context.read<FincasListBloc>().state.selectedFincaId;
                  context.read<DashboardSummaryBloc>().add(
                        DashboardSummaryRefreshed(tenantId, fincaId: fincaId),
                      );
                },
              );
            }
            return const _SkeletonView();
          }

          final data = state.data!;
          return RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: () async {
              final tenantId =
                  context.read<AuthBloc>().state.user?.tenantId ?? '';
              final fincaId =
                  context.read<FincasListBloc>().state.selectedFincaId;
              context.read<DashboardSummaryBloc>().add(
                    DashboardSummaryRefreshed(tenantId, fincaId: fincaId),
                  );
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(child: DashboardHeader()),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ExportPdfButton(
                          data: data,
                          userName: context.read<AuthBloc>().state.user?.nombre ?? '',
                          tenantId: context.read<AuthBloc>().state.user?.tenantId ?? '',
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.fromCache)
                  const SliverToBoxAdapter(child: _CacheBanner()),
                // Inteligencia (lazy) en el tope del scroll, justo después
                // del header. La carga del endpoint costoso se dispara la
                // primera vez que se pinta — el resto del dashboard sigue
                // renderizando en paralelo sin esperarla.
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _InteligenciaSection(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                  sliver: SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // En pantallas < 500px (móvil), todo en 1 columna.
                        // En pantallas >= 500px (tablet/desktop), 2 columnas.
                        final isWide = constraints.maxWidth >= 500;
                        final cols = isWide ? 2 : 1;
                        return StaggeredGrid.count(
                          crossAxisCount: cols,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          children: [
                            // KPI Sparklines — 2x2 en desktop, 1 col en móvil
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: KpiSparklineCard(
                                label: 'Animales registrados',
                                value: '${data.demography.total}',
                                trend: data.trends.animales,
                                icon: Icons.pets_rounded,
                              ),
                            ),
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: KpiSparklineCard(
                                label: 'Ingresos',
                                value: '\$${(data.financesSummary.totalIngresos / 1000000).toStringAsFixed(1)}M',
                                trend: data.trends.ingresos,
                                icon: Icons.trending_up_rounded,
                                accentColor: const Color(0xFF16A34A),
                              ),
                            ),
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: KpiSparklineCard(
                                label: 'Gastos',
                                value: '\$${(data.financesSummary.totalGastos / 1000000).toStringAsFixed(1)}M',
                                trend: data.trends.gastos,
                                icon: Icons.trending_down_rounded,
                                accentColor: const Color(0xFFEF4444),
                              ),
                            ),
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: KpiSparklineCard(
                                label: 'Eventos de salud',
                                value: '${data.trends.salud.lastValue.round()}',
                                trend: data.trends.salud,
                                icon: Icons.medical_services_rounded,
                                accentColor: const Color(0xFF3B82F6),
                              ),
                            ),
                            // Demografía — siempre ancho completo
                            StaggeredGridTile.fit(
                              crossAxisCellCount: cols,
                              child: DemographyCard(data: data.demography)
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 0.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // Género split — full en móvil, mitad en desktop
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: GenderSplitCard(data: data.genderSplit)
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 80.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // Ocupación — full en móvil, mitad en desktop
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: OccupancyCard(data: data.occupancy)
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 120.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // Finanzas — siempre completo
                            StaggeredGridTile.fit(
                              crossAxisCellCount: cols,
                              child: FinancesBarCard(
                                      data: data.financesSummary)
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 160.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // Mapa visual de la finca (grid de potreros)
                            StaggeredGridTile.fit(
                              crossAxisCellCount: cols,
                              child: FarmMapCard(
                                      potreros: data.allPotreros)
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 200.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // Top 5 potreros por carga
                            StaggeredGridTile.fit(
                              crossAxisCellCount: cols,
                              child: TopPotrerosCard(
                                      potreros: data.topPotreros)
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 220.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // Alertas — full en móvil, mitad en desktop
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: CriticalAlertsCard(
                                alerts: data.criticalAlerts,
                                onCreateHealthRecord: () =>
                                    context.push('/health/salud/new'),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 240.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // Movimientos — full en móvil, mitad en desktop
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: RecentMovementsCard(
                                movements: data.recentMovements,
                                onCreateMovement: () =>
                                    context.push(RoutePaths.inventory),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 280.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // IA Predicciones — full en móvil, mitad en desktop
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: const IaPredictionsCard()
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 320.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                            // IA Recomendaciones — full en móvil, mitad en desktop
                            StaggeredGridTile.fit(
                              crossAxisCellCount: isWide ? 1 : cols,
                              child: const IaRecommendationsCard()
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 360.ms)
                                  .slideY(begin: 0.05, end: 0),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
          );
        },
      ),
    );
  }
}

/// Sección lazy del dashboard que consume `/dashboard/inteligencia`.
///
/// Se dispara una sola vez en `initState` (la sección está al final del
/// scroll, así que llegar a ella ya implica que el usuario quiere verla).
/// El refresh por rotación de finca lo maneja `HomeShell` vía
/// `BlocListener<FincasListBloc>`.
class _InteligenciaSection extends StatefulWidget {
  const _InteligenciaSection();

  @override
  State<_InteligenciaSection> createState() => _InteligenciaSectionState();
}

class _InteligenciaSectionState extends State<_InteligenciaSection> {
  @override
  void initState() {
    super.initState();
    // Disparamos solo si todavía no hay data — evita recargas dobles si el
    // usuario hace scroll arriba/abajo.
    final bloc = context.read<DashboardInteligenciaBloc>();
    if (bloc.state.status == DashboardInteligenciaStatus.initial) {
      final fincaId = context.read<FincasListBloc>().state.selectedFincaId;
      bloc.add(DashboardInteligenciaRequested(fincaId: fincaId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<DashboardInteligenciaBloc, DashboardInteligenciaState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de sección
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 14),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Inteligencia',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            _InteligenciaBody(state: state),
          ],
        );
      },
    );
  }
}

class _InteligenciaBody extends StatelessWidget {
  final DashboardInteligenciaState state;
  const _InteligenciaBody({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case DashboardInteligenciaStatus.initial:
      case DashboardInteligenciaStatus.loading:
        return const _InteligenciaSkeleton();
      case DashboardInteligenciaStatus.error:
        return _InteligenciaError(
          message: state.failure?.message ??
              'No se pudo cargar la inteligencia del dashboard',
          onRetry: () {
            final fincaId =
                context.read<FincasListBloc>().state.selectedFincaId;
            context.read<DashboardInteligenciaBloc>().add(
                  DashboardInteligenciaRequested(fincaId: fincaId),
                );
          },
        );
      case DashboardInteligenciaStatus.loaded:
        final data = state.data;
        if (data == null) return const SizedBox.shrink();
        return _InteligenciaContent(data: data);
    }
  }
}

class _InteligenciaContent extends StatelessWidget {
  final DashboardInteligencia data;
  const _InteligenciaContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.animalesSinPotrero > 0) ...[
          AnimalesSinPotreroChip(count: data.animalesSinPotrero),
          const SizedBox(height: 14),
        ],
        GananciaCard(data: data.estimacionGanancia),
        const SizedBox(height: 14),
        TopAnimalesCostososCard(animales: data.topAnimalesCostosos),
      ],
    );
  }
}

class _InteligenciaSkeleton extends StatelessWidget {
  const _InteligenciaSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(2, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: i == 0 ? 160 : 220,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms, begin: 0.4),
        );
      }),
    );
  }
}

class _InteligenciaError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InteligenciaError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _SkeletonView extends StatelessWidget {
  const _SkeletonView();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: AppDashboardSkeleton(),
    );
  }
}

class _CacheBanner extends StatelessWidget {
  const _CacheBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Mostrando datos guardados · actualizando…',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
