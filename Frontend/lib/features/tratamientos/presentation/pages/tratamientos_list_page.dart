import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/tratamiento.dart';
import '../bloc/tratamientos_bloc.dart';

class TratamientosListPage extends StatelessWidget {
  const TratamientosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TratamientosBloc>(
      create: (_) => getIt<TratamientosBloc>()..add(const TratamientosStarted()),
      child: const _TratamientosView(),
    );
  }
}

class _TratamientosView extends StatelessWidget {
  const _TratamientosView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<TratamientosBloc, TratamientosState>(
        builder: (context, state) {
          return Column(
            children: [
              const SectionHeader(
                title: 'Tratamientos',
                subtitle: 'Historial clínico de animales',
                showBack: true,
              ),
              Expanded(
                child: switch (state.status) {
                  TratamientosStatus.initial || TratamientosStatus.loading => const AppLoading(),
                  TratamientosStatus.error => Center(child: Text(state.error ?? 'Error')),
                  TratamientosStatus.loaded => state.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIcons.firstAid(PhosphorIconsStyle.bold), size: 64, color: cs.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text('No hay tratamientos registrados', style: TextStyle(color: cs.onSurfaceVariant)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => context.read<TratamientosBloc>().add(const TratamientosRefreshed()),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                            itemCount: state.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final t = state.items[i];
                              final color = switch (t.estado) {
                                EstadoTratamiento.enCurso => cs.tertiary,
                                EstadoTratamiento.completado => cs.primary,
                                EstadoTratamiento.abandonado => cs.error,
                              };
                              return Container(
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border(left: BorderSide(color: color, width: 4)),
                                ),
                                child: ListTile(
                                  title: Text(t.diagnostico, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Animal #${t.fkIdBovino}'),
                                      Text(t.veterinario?.nombre ?? 'Sin veterinario', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                                    child: Text(t.estado.label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
                                  ),
                                  onTap: () => context.push('/health/tratamientos/${t.id}'),
                                ),
                              );
                            },
                          ),
                        ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
