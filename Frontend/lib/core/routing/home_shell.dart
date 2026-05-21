import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../widgets/app_squircle_fab.dart';
import '../widgets/quick_create_sheet.dart';
import '../../features/animales/presentation/bloc/animales_list_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_inteligencia_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_summary_bloc.dart';
import '../../features/dashboard/presentation/widgets/home_bottom_nav.dart';
import '../../features/finanzas/presentation/bloc/finanzas_list_bloc.dart';
import '../../features/finanzas/presentation/bloc/finanzas_resumen_bloc.dart';
import '../../features/fincas/presentation/bloc/fincas_list_bloc.dart';
import '../../features/potreros/presentation/bloc/potreros_list_bloc.dart';
import '../../features/reproduccion/presentation/bloc/reproduccion_list_bloc.dart';
import '../../features/salud/presentation/bloc/salud_list_bloc.dart';
import '../../features/ia/presentation/bloc/predictions_bloc.dart';
import '../../features/ia/presentation/bloc/recommendations_bloc.dart';
import '../../features/ia/presentation/bloc/chat_bloc.dart';
import '../../features/ia/presentation/widgets/ai_chat_fab.dart';
import 'route_paths.dart';

/// Cascarón común a todas las pantallas dentro del shell con bottom nav.
///
/// Provee al subárbol los blocs de scope-shell:
/// - `FincasListBloc` para el selector global de finca.
/// - `DashboardSummaryBloc` para los KPIs de la home (Bento).
///
/// Un `BlocListener` puentea ambos: cuando el usuario cambia la finca activa
/// en `FincasListBloc.selectedFincaId`, se dispara automáticamente un
/// `DashboardSummaryRefreshed(tenantId, fincaId)` para recargar los KPIs
/// filtrados.
class HomeShell extends StatelessWidget {
  final Widget child;
  final String location;

  const HomeShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final showFab = location == RoutePaths.home;
    final tenantId = context.read<AuthBloc>().state.user?.tenantId ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<FincasListBloc>.value(
          value: getIt<FincasListBloc>()..add(const FincasListStarted()),
        ),
        BlocProvider<DashboardSummaryBloc>(
          create: (_) => getIt<DashboardSummaryBloc>()
            ..add(DashboardSummaryStarted(tenantId)),
        ),
        // El bloc de inteligencia vive a la par del summary porque el
        // listener de rotación de finca debe poder dispararle un refresh.
        // No se carga en initState — la `_InteligenciaSection` del Bento
        // dispara la primera carga lazy cuando se construye.
        BlocProvider<DashboardInteligenciaBloc>(
          create: (_) => getIt<DashboardInteligenciaBloc>(),
        ),
        BlocProvider<PredictionsBloc>(
          create: (_) => getIt<PredictionsBloc>(),
        ),
        BlocProvider<RecommendationsBloc>(
          create: (_) => getIt<RecommendationsBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => getIt<ChatBloc>(),
        ),
      ],
      child: BlocListener<FincasListBloc, FincasListState>(
        listenWhen: (prev, curr) =>
            prev.selectedFincaId != curr.selectedFincaId,
        listener: (context, state) {
          context.read<DashboardSummaryBloc>().add(
                DashboardSummaryRefreshed(
                  tenantId,
                  fincaId: state.selectedFincaId,
                ),
              );
          // Solo recargamos inteligencia si ya se había cargado antes
          // (estado no-initial). Si el usuario nunca abrió la sección,
          // no pagamos el round-trip.
          final inteligenciaBloc = context.read<DashboardInteligenciaBloc>();
          if (inteligenciaBloc.state.status !=
              DashboardInteligenciaStatus.initial) {
            inteligenciaBloc.add(
              DashboardInteligenciaRequested(fincaId: state.selectedFincaId),
            );
          }
          // Propaga la rotación de finca a los listados singleton del shell.
          // Cada bloc hace no-op cuando la finca pedida coincide con la
          // actual, así que sólo paga round-trip lo que realmente cambia.
          // Los blocs que aún están en `initial` (tabs nunca abiertos)
          // recibirán la finca cuando el usuario entre a la pantalla.
          final animalesBloc = getIt<AnimalesListBloc>();
          if (animalesBloc.state.status != AnimalesListStatus.initial) {
            animalesBloc.add(
              AnimalesListFincaFilterChanged(fincaId: state.selectedFincaId),
            );
          }
          final potrerosBloc = getIt<PotrerosListBloc>();
          if (potrerosBloc.state.status != PotrerosListStatus.initial) {
            potrerosBloc.add(
              PotrerosListFincaFilterChanged(fincaId: state.selectedFincaId),
            );
          }
          final saludBloc = getIt<SaludListBloc>();
          if (saludBloc.state.status != SaludListStatus.initial) {
            saludBloc.add(
              SaludListFincaFilterChanged(fincaId: state.selectedFincaId),
            );
          }
          final reproduccionBloc = getIt<ReproduccionListBloc>();
          if (reproduccionBloc.state.status !=
              ReproduccionListStatus.initial) {
            reproduccionBloc.add(
              ReproduccionListFincaFilterChanged(
                fincaId: state.selectedFincaId,
              ),
            );
          }
          final finanzasListBloc = getIt<FinanzasListBloc>();
          if (finanzasListBloc.state.status != FinanzasListStatus.initial) {
            finanzasListBloc.add(
              FinanzasListFincaFilterChanged(fincaId: state.selectedFincaId),
            );
          }
          final finanzasResumenBloc = getIt<FinanzasResumenBloc>();
          if (finanzasResumenBloc.state.status !=
              FinanzasResumenStatus.initial) {
            finanzasResumenBloc.add(
              FinanzasResumenFincaFilterChanged(
                fincaId: state.selectedFincaId,
              ),
            );
          }
        },
        child: Scaffold(
          body: child,
          floatingActionButton: showFab
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AiChatFab(),
                    const SizedBox(height: 16),
                    AppSquircleFab(
                      onPressed: () => _openQuickCreate(context),
                    ),
                  ],
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: HomeBottomNav(
            currentLocation: location,
            onTap: (path) {
              if (path != location) context.go(path);
            },
          ),
        ),
      ),
    );
  }

  void _openQuickCreate(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const QuickCreateSheet(),
    );
  }
}
