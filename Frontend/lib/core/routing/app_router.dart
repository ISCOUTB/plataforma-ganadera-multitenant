import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/alertas/presentation/pages/alertas_page.dart';
import '../../features/alimentos/presentation/pages/alimento_form_page.dart';
import '../../features/alimentos/presentation/pages/alimentos_list_page.dart';
import '../../features/animales/presentation/pages/animal_detail_page.dart';
import '../../features/animales/presentation/pages/animal_form_page.dart';
import '../../features/animales/presentation/pages/animales_list_page.dart';
import '../../features/bovino_alimento/presentation/pages/bovino_alimento_list_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_bento_page.dart';
import '../../features/finanzas/presentation/pages/finanza_form_page.dart';
import '../../features/finanzas/presentation/pages/finanzas_list_page.dart';
import '../../features/fincas/presentation/pages/finca_detail_page.dart';
import '../../features/fincas/presentation/pages/finca_form_page.dart';
import '../../features/fincas/presentation/pages/fincas_list_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/money/presentation/pages/money_page.dart';
import '../../features/movimientos/presentation/pages/movimiento_form_page.dart';
import '../../features/movimientos/presentation/pages/movimientos_list_page.dart';
import '../../features/potreros/presentation/pages/potrero_detail_page.dart';
import '../../features/potreros/presentation/pages/potrero_form_page.dart';
import '../../features/potreros/presentation/pages/potreros_list_page.dart';
import '../../features/reproduccion/presentation/pages/reproduccion_form_page.dart';
import '../../features/reproduccion/presentation/pages/reproduccion_list_page.dart';
import '../../features/salud/presentation/pages/salud_detail_page.dart';
import '../../features/salud/presentation/pages/salud_form_page.dart';
import '../../features/salud/presentation/pages/salud_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/usuarios/presentation/pages/usuarios_page.dart';
import '../../features/admin/presentation/pages/admin_panel_page.dart';
import '../../features/landing/presentation/pages/landing_page.dart';
import 'home_shell.dart';
import 'route_paths.dart';

GoRouter buildAppRouter(AuthBloc authBloc) {
  final notifier = _AuthNotifier(authBloc);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final status = authBloc.state.status;
      final goingTo = state.matchedLocation;

      final isPublicRoute = goingTo == RoutePaths.login ||
          goingTo == RoutePaths.register ||
          goingTo == '/';
      final isSplash = goingTo == RoutePaths.splash;

      switch (status) {
        case AuthStatus.initial:
        case AuthStatus.loading:
          return isSplash ? null : RoutePaths.splash;

        case AuthStatus.authenticated:
          if (isSplash || isPublicRoute) return RoutePaths.home;
          return null;

        case AuthStatus.unauthenticated:
        case AuthStatus.failure:
          if (isPublicRoute) return null;
          return '/';
      }
    },
    routes: [
      // Landing (pre-auth marketing page)
      GoRoute(path: '/', builder: (_, _) => const LandingPage()),

      // Auth routes (sin shell)
      GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginPage()),
      GoRoute(
          path: RoutePaths.register, builder: (_, _) => const RegisterPage()),

      // Shell con bottom nav
      ShellRoute(
        builder: (context, state, child) => HomeShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          // HOME
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: DashboardBentoPage()),
          ),

          // INVENTORY hub + sub-rutas
          GoRoute(
            path: RoutePaths.inventory,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: InventoryPage()),
            routes: [
              // Animales
              GoRoute(
                path: 'animales',
                builder: (_, _) => const AnimalesListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const AnimalFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => AnimalDetailPage(
                      animalId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => AnimalFormPage(
                          editId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                      GoRoute(
                        path: 'alimentacion',
                        builder: (context, state) => BovinoAlimentoListPage(
                          animalId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Fincas
              GoRoute(
                path: 'fincas',
                builder: (_, _) => const FincasListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const FincaFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        FincaDetailPage(fincaId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => FincaFormPage(
                          editId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Potreros
              GoRoute(
                path: 'potreros',
                builder: (_, _) => const PotrerosListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const PotreroFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => PotreroDetailPage(
                      potreroId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => PotreroFormPage(
                          editId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // HEALTH hub + sub-rutas
          GoRoute(
            path: RoutePaths.health,
            pageBuilder: (_, _) => const NoTransitionPage(child: HealthPage()),
            routes: [
              // Salud
              GoRoute(
                path: 'salud',
                builder: (_, _) => const SaludListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const SaludFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => SaludDetailPage(
                      saludId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => SaludFormPage(
                          editId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Reproducción
              GoRoute(
                path: 'reproduccion',
                builder: (_, _) => const ReproduccionListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const ReproduccionFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ReproduccionFormPage(
                      editId: state.pathParameters['id'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => ReproduccionFormPage(
                          editId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Centro de alertas consolidado
              GoRoute(
                path: 'alertas',
                builder: (_, _) => const AlertasPage(),
              ),
            ],
          ),

          // MONEY hub + sub-rutas
          GoRoute(
            path: RoutePaths.money,
            pageBuilder: (_, _) => const NoTransitionPage(child: MoneyPage()),
            routes: [
              // Finanzas
              GoRoute(
                path: 'finanzas',
                builder: (_, _) => const FinanzasListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const FinanzaFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => FinanzaFormPage(
                      editId: state.pathParameters['id'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => FinanzaFormPage(
                          editId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Alimentos
              GoRoute(
                path: 'alimentos',
                builder: (_, _) => const AlimentosListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const AlimentoFormPage(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => AlimentoFormPage(
                      editId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
              // Movimientos
              GoRoute(
                path: 'movimientos',
                builder: (_, _) => const MovimientosListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const MovimientoFormPage(),
                  ),
                ],
              ),
            ],
          ),

          // SETTINGS + sub-rutas
          GoRoute(
            path: RoutePaths.settings,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SettingsPage()),
            routes: [
              GoRoute(
                path: 'usuarios',
                builder: (_, _) => const UsuariosPage(),
              ),
              GoRoute(
                path: 'admin',
                builder: (_, _) => const AdminPanelPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _AuthNotifier(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
