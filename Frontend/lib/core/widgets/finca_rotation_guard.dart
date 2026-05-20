import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/fincas/presentation/bloc/fincas_list_bloc.dart';

/// Cierra una pantalla de detalle cuando el usuario rota la finca activa
/// desde el selector global. Sin esto el detalle sigue mostrando un
/// recurso que ya no pertenece a la finca seleccionada y rompe la promesa
/// del filtro global.
///
/// Hace `pop()` si hay ruta de la cual volver, en caso contrario
/// reemplaza por [fallbackRoute] (típicamente la lista padre).
class FincaRotationGuard extends StatelessWidget {
  final Widget child;
  final String fallbackRoute;

  const FincaRotationGuard({
    super.key,
    required this.child,
    required this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<FincasListBloc, FincasListState>(
      listenWhen: (prev, curr) =>
          prev.selectedFincaId != curr.selectedFincaId,
      listener: (context, _) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(fallbackRoute);
        }
      },
      child: child,
    );
  }
}
