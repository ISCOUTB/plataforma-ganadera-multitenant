import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locale/locale_controller.dart';
import '../theme/theme_controller.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../routing/auth_event_bus.dart';
import '../storage/secure_storage_service.dart';
// Veterinarios
import '../../features/veterinarios/data/datasources/veterinarios_remote_datasource.dart';
import '../../features/veterinarios/data/repositories/veterinarios_repository_impl.dart';
import '../../features/veterinarios/domain/repositories/veterinarios_repository.dart';
import '../../features/veterinarios/presentation/bloc/veterinarios_bloc.dart';
// Citas
import '../../features/citas/data/datasources/citas_remote_datasource.dart';
import '../../features/citas/data/repositories/citas_repository_impl.dart';
import '../../features/citas/domain/repositories/citas_repository.dart';
import '../../features/citas/presentation/bloc/citas_bloc.dart';
// Tratamientos
import '../../features/tratamientos/data/datasources/tratamientos_remote_datasource.dart';
import '../../features/tratamientos/data/repositories/tratamientos_repository_impl.dart';
import '../../features/tratamientos/domain/repositories/tratamientos_repository.dart';
import '../../features/tratamientos/presentation/bloc/tratamientos_bloc.dart';
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart';
import '../../features/animales/data/datasources/animal_remote_datasource.dart';
import '../../features/animales/data/repositories/animal_repository_impl.dart';
import '../../features/animales/domain/repositories/animal_repository.dart';
import '../../features/animales/presentation/bloc/animal_detail_bloc.dart';
import '../../features/animales/presentation/bloc/animal_form_bloc.dart';
import '../../features/animales/presentation/bloc/animales_list_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/hydrate_session_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_inteligencia_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_summary_bloc.dart';
import '../../features/fincas/data/datasources/finca_remote_datasource.dart';
import '../../features/fincas/data/repositories/finca_repository_impl.dart';
import '../../features/fincas/domain/repositories/finca_repository.dart';
import '../../features/fincas/presentation/bloc/finca_detail_bloc.dart';
import '../../features/fincas/presentation/bloc/finca_form_bloc.dart';
import '../../features/fincas/presentation/bloc/fincas_list_bloc.dart';
import '../../features/potreros/data/datasources/potrero_remote_datasource.dart';
import '../../features/potreros/data/repositories/potrero_repository_impl.dart';
import '../../features/potreros/domain/repositories/potrero_repository.dart';
import '../../features/potreros/presentation/bloc/potrero_detail_bloc.dart';
import '../../features/potreros/presentation/bloc/potrero_form_bloc.dart';
import '../../features/potreros/presentation/bloc/potreros_list_bloc.dart';
// Salud
import '../../features/salud/data/datasources/salud_remote_datasource.dart';
import '../../features/salud/data/repositories/salud_repository_impl.dart';
import '../../features/salud/domain/repositories/salud_repository.dart';
import '../../features/salud/presentation/bloc/salud_alertas_bloc.dart';
import '../../features/salud/presentation/bloc/salud_detail_bloc.dart';
import '../../features/salud/presentation/bloc/salud_form_bloc.dart';
import '../../features/salud/presentation/bloc/salud_list_bloc.dart';
// Reproducción
import '../../features/reproduccion/data/datasources/reproduccion_remote_datasource.dart';
import '../../features/reproduccion/data/repositories/reproduccion_repository_impl.dart';
import '../../features/reproduccion/domain/repositories/reproduccion_repository.dart';
import '../../features/reproduccion/presentation/bloc/reproduccion_form_bloc.dart';
import '../../features/reproduccion/presentation/bloc/reproduccion_list_bloc.dart';
// Alertas
import '../../features/alertas/data/datasources/alertas_remote_datasource.dart';
import '../../features/alertas/data/repositories/alertas_repository_impl.dart';
import '../../features/alertas/domain/repositories/alertas_repository.dart';
import '../../features/alertas/presentation/bloc/alertas_bloc.dart';
// Finanzas
import '../../features/finanzas/data/datasources/finanza_remote_datasource.dart';
import '../../features/finanzas/data/repositories/finanza_repository_impl.dart';
import '../../features/finanzas/domain/repositories/finanza_repository.dart';
import '../../features/finanzas/presentation/bloc/finanza_form_bloc.dart';
import '../../features/finanzas/presentation/bloc/finanzas_list_bloc.dart';
import '../../features/finanzas/presentation/bloc/finanzas_resumen_bloc.dart';
// Alimentos
import '../../features/alimentos/data/datasources/alimento_remote_datasource.dart';
import '../../features/alimentos/data/repositories/alimento_repository_impl.dart';
import '../../features/alimentos/domain/repositories/alimento_repository.dart';
import '../../features/alimentos/presentation/bloc/alimento_form_bloc.dart';
import '../../features/alimentos/presentation/bloc/alimentos_list_bloc.dart';
// Movimientos
import '../../features/movimientos/data/datasources/movimiento_remote_datasource.dart';
import '../../features/movimientos/data/repositories/movimiento_repository_impl.dart';
import '../../features/movimientos/domain/repositories/movimiento_repository.dart';
import '../../features/movimientos/presentation/bloc/movimiento_form_bloc.dart';
import '../../features/movimientos/presentation/bloc/movimientos_list_bloc.dart';
// Usuarios del tenant
import '../../features/usuarios/data/datasources/usuarios_remote_datasource.dart';
import '../../features/usuarios/data/repositories/usuarios_repository_impl.dart';
import '../../features/usuarios/domain/repositories/usuarios_repository.dart';
import '../../features/usuarios/presentation/bloc/usuarios_bloc.dart';
// Bovino-Alimento
import '../../features/bovino_alimento/data/datasources/bovino_alimento_remote_datasource.dart';
import '../../features/bovino_alimento/data/repositories/bovino_alimento_repository_impl.dart';
import '../../features/bovino_alimento/domain/repositories/bovino_alimento_repository.dart';
import '../../features/bovino_alimento/presentation/bloc/bovino_alimento_bloc.dart';
// Admin
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
// IA
import '../../features/ia/data/datasources/ia_remote_data_source.dart';
import '../../features/ia/data/repositories/ia_repository_impl.dart';
import '../../features/ia/domain/repositories/ia_repository.dart';
import '../../features/ia/presentation/bloc/chat_bloc.dart';
import '../../features/ia/presentation/bloc/predictions_bloc.dart';
import '../../features/ia/presentation/bloc/recommendations_bloc.dart';

/// Contenedor global de inyección de dependencias.
final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ---------- Core: async singletons (requieren await) ----------
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // ---------- Core ----------
  getIt.registerSingleton<LocaleController>(
    LocaleController(getIt<SharedPreferences>()),
  );
  getIt.registerSingleton<ThemeController>(
    ThemeController(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  getIt.registerLazySingleton<AuthEventBus>(() => AuthEventBus());
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      storage: getIt<SecureStorageService>(),
      eventBus: getIt<AuthEventBus>(),
      refreshDio: DioClient.buildRefreshDio(),
    ),
  );
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(authInterceptor: getIt<AuthInterceptor>()),
  );

  // ---------- Auth ----------
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      storage: getIt<SecureStorageService>(),
    ),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetMeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => HydrateSessionUseCase(
      repository: getIt<AuthRepository>(),
      storage: getIt<SecureStorageService>(),
    ),
  );
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      hydrateSessionUseCase: getIt<HydrateSessionUseCase>(),
      eventBus: getIt<AuthEventBus>(),
    ),
  );

  // ---------- Dashboard ----------
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSource(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remote: getIt<DashboardRemoteDataSource>(),
      local: getIt<DashboardLocalDataSource>(),
    ),
  );
  getIt.registerFactory<DashboardSummaryBloc>(
    () => DashboardSummaryBloc(repository: getIt<DashboardRepository>()),
  );
  getIt.registerFactory<DashboardInteligenciaBloc>(
    () => DashboardInteligenciaBloc(repository: getIt<DashboardRepository>()),
  );

  // ---------- Fincas ----------
  getIt.registerLazySingleton<FincaRemoteDataSource>(
    () => FincaRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<FincaRepository>(
    () => FincaRepositoryImpl(remote: getIt<FincaRemoteDataSource>()),
  );
  // Singleton: persiste el state entre navegaciones (no recarga al volver
  // del detalle a la lista). Se reinicia al hacer logout en Fase E.
  getIt.registerLazySingleton<FincasListBloc>(
    () => FincasListBloc(repository: getIt<FincaRepository>()),
  );
  getIt.registerFactory<FincaDetailBloc>(
    () => FincaDetailBloc(
      repository: getIt<FincaRepository>(),
      remote: getIt<FincaRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<FincaFormBloc>(
    () => FincaFormBloc(repository: getIt<FincaRepository>()),
  );

  // ---------- Potreros ----------
  getIt.registerLazySingleton<PotreroRemoteDataSource>(
    () => PotreroRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<PotreroRepository>(
    () => PotreroRepositoryImpl(remote: getIt<PotreroRemoteDataSource>()),
  );
  getIt.registerLazySingleton<PotrerosListBloc>(
    () => PotrerosListBloc(repository: getIt<PotreroRepository>()),
  );
  getIt.registerFactory<PotreroDetailBloc>(
    () => PotreroDetailBloc(
      repository: getIt<PotreroRepository>(),
      remote: getIt<PotreroRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<PotreroFormBloc>(
    () => PotreroFormBloc(repository: getIt<PotreroRepository>()),
  );

  // ---------- Animales ----------
  getIt.registerLazySingleton<AnimalRemoteDataSource>(
    () => AnimalRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<AnimalRepository>(
    () => AnimalRepositoryImpl(remote: getIt<AnimalRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AnimalesListBloc>(
    () => AnimalesListBloc(repository: getIt<AnimalRepository>()),
  );
  getIt.registerFactory<AnimalDetailBloc>(
    () => AnimalDetailBloc(repository: getIt<AnimalRepository>()),
  );
  getIt.registerFactory<AnimalFormBloc>(
    () => AnimalFormBloc(repository: getIt<AnimalRepository>()),
  );

  // ---------- Salud ----------
  getIt.registerLazySingleton<SaludRemoteDataSource>(
    () => SaludRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<SaludRepository>(
    () => SaludRepositoryImpl(remote: getIt<SaludRemoteDataSource>()),
  );
  getIt.registerLazySingleton<SaludListBloc>(
    () => SaludListBloc(repository: getIt<SaludRepository>()),
  );
  getIt.registerFactory<SaludDetailBloc>(
    () => SaludDetailBloc(repository: getIt<SaludRepository>()),
  );
  getIt.registerFactory<SaludFormBloc>(
    () => SaludFormBloc(repository: getIt<SaludRepository>()),
  );
  getIt.registerFactory<SaludAlertasBloc>(
    () => SaludAlertasBloc(repository: getIt<SaludRepository>()),
  );

  // ---------- Reproducción ----------
  getIt.registerLazySingleton<ReproduccionRemoteDataSource>(
    () => ReproduccionRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<ReproduccionRepository>(
    () => ReproduccionRepositoryImpl(
      remote: getIt<ReproduccionRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<ReproduccionListBloc>(
    () => ReproduccionListBloc(repository: getIt<ReproduccionRepository>()),
  );
  getIt.registerFactory<ReproduccionFormBloc>(
    () => ReproduccionFormBloc(repository: getIt<ReproduccionRepository>()),
  );

  // ---------- Alertas consolidadas ----------
  getIt.registerLazySingleton<AlertasRemoteDataSource>(
    () => AlertasRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<AlertasRepository>(
    () => AlertasRepositoryImpl(remote: getIt<AlertasRemoteDataSource>()),
  );
  getIt.registerFactory<AlertasBloc>(
    () => AlertasBloc(repository: getIt<AlertasRepository>()),
  );

  // ---------- Finanzas ----------
  getIt.registerLazySingleton<FinanzaRemoteDataSource>(
    () => FinanzaRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<FinanzaRepository>(
    () => FinanzaRepositoryImpl(remote: getIt<FinanzaRemoteDataSource>()),
  );
  getIt.registerLazySingleton<FinanzasListBloc>(
    () => FinanzasListBloc(repository: getIt<FinanzaRepository>()),
  );
  getIt.registerLazySingleton<FinanzasResumenBloc>(
    () => FinanzasResumenBloc(repository: getIt<FinanzaRepository>()),
  );
  getIt.registerFactory<FinanzaFormBloc>(
    () => FinanzaFormBloc(repository: getIt<FinanzaRepository>()),
  );

  // ---------- Alimentos ----------
  getIt.registerLazySingleton<AlimentoRemoteDataSource>(
    () => AlimentoRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<AlimentoRepository>(
    () => AlimentoRepositoryImpl(remote: getIt<AlimentoRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AlimentosListBloc>(
    () => AlimentosListBloc(repository: getIt<AlimentoRepository>()),
  );
  getIt.registerFactory<AlimentoFormBloc>(
    () => AlimentoFormBloc(repository: getIt<AlimentoRepository>()),
  );

  // ---------- Movimientos ----------
  getIt.registerLazySingleton<MovimientoRemoteDataSource>(
    () => MovimientoRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<MovimientoRepository>(
    () => MovimientoRepositoryImpl(
      remote: getIt<MovimientoRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<MovimientosListBloc>(
    () => MovimientosListBloc(repository: getIt<MovimientoRepository>()),
  );
  getIt.registerFactory<MovimientoFormBloc>(
    () => MovimientoFormBloc(repository: getIt<MovimientoRepository>()),
  );

  // ---------- Usuarios del tenant ----------
  getIt.registerLazySingleton<UsuariosRemoteDataSource>(
    () => UsuariosRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<UsuariosRepository>(
    () => UsuariosRepositoryImpl(remote: getIt<UsuariosRemoteDataSource>()),
  );
  getIt.registerFactory<UsuariosBloc>(
    () => UsuariosBloc(repository: getIt<UsuariosRepository>()),
  );

  // ---------- Bovino-Alimento (N:N) ----------
  getIt.registerLazySingleton<BovinoAlimentoRemoteDataSource>(
    () => BovinoAlimentoRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<BovinoAlimentoRepository>(
    () => BovinoAlimentoRepositoryImpl(
      remote: getIt<BovinoAlimentoRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<BovinoAlimentoBloc>(
    () => BovinoAlimentoBloc(repository: getIt<BovinoAlimentoRepository>()),
  );

  // ---------- Admin (superadmin) ----------
  getIt.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remote: getIt<AdminRemoteDataSource>()),
  );
  getIt.registerFactory<AdminBloc>(
    () => AdminBloc(repository: getIt<AdminRepository>()),
  );
  // ---------- Veterinarios ----------
  getIt.registerLazySingleton<VeterinariosRemoteDataSource>(
    () => VeterinariosRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<VeterinariosRepository>(
    () => VeterinariosRepositoryImpl(remote: getIt<VeterinariosRemoteDataSource>()),
  );
  getIt.registerFactory<VeterinariosBloc>(
    () => VeterinariosBloc(repository: getIt<VeterinariosRepository>()),
  );

  // ---------- Citas ----------
  getIt.registerLazySingleton<CitasRemoteDataSource>(
    () => CitasRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<CitasRepository>(
    () => CitasRepositoryImpl(remote: getIt<CitasRemoteDataSource>()),
  );
  getIt.registerFactory<CitasBloc>(
    () => CitasBloc(repository: getIt<CitasRepository>()),
  );

  // ---------- Tratamientos ----------
  getIt.registerLazySingleton<TratamientosRemoteDataSource>(
    () => TratamientosRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<TratamientosRepository>(
    () => TratamientosRepositoryImpl(remote: getIt<TratamientosRemoteDataSource>()),
  );
  getIt.registerFactory<TratamientosBloc>(
    () => TratamientosBloc(repository: getIt<TratamientosRepository>()),
  );

  // ---------- IA (Asistente, Predicciones, Recomendaciones) ----------
  getIt.registerLazySingleton<IaRemoteDataSource>(
    () => IaRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<IaRepository>(
    () => IaRepositoryImpl(remoteDataSource: getIt<IaRemoteDataSource>()),
  );
  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(repository: getIt<IaRepository>()),
  );
  getIt.registerFactory<PredictionsBloc>(
    () => PredictionsBloc(repository: getIt<IaRepository>()),
  );
  getIt.registerFactory<RecommendationsBloc>(
    () => RecommendationsBloc(repository: getIt<IaRepository>()),
  );
}
