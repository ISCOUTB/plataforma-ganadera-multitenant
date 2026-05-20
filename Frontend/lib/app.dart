import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/locale/locale_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'l10n/app_localizations.dart';

class FarmLinkApp extends StatelessWidget {
  const FarmLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(const AuthAppStarted()),
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final router = buildAppRouter(authBloc);
          final localeCtrl = getIt<LocaleController>();
          final themeCtrl = getIt<ThemeController>();

          return ValueListenableBuilder<Locale>(
            valueListenable: localeCtrl,
            builder: (context, locale, _) {
              return ValueListenableBuilder<ThemeMode>(
                valueListenable: themeCtrl,
                builder: (context, themeMode, _) {
                  return MaterialApp.router(
                    title: 'FarmLink',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                    routerConfig: router,
                    locale: locale,
                    supportedLocales: S.supportedLocales,
                    localizationsDelegates: const [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
