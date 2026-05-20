import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa los datos de locale de `intl` para que DateFormat('es') y
  // NumberFormat.currency(locale: 'es_CO') funcionen sin lanzar
  // LocaleDataException al construir widgets con fechas/moneda.
  await initializeDateFormatting('es', null);
  await configureDependencies();
  runApp(const FarmLinkApp());
}
