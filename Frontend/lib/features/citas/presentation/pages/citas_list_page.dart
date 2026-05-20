import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/cita.dart';
import '../bloc/citas_bloc.dart';

class CitasListPage extends StatelessWidget {
  const CitasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CitasBloc>(
      create: (_) => getIt<CitasBloc>()..add(const CitasStarted()),
      child: const _CitasView(),
    );
  }
}

class _CitasView extends StatelessWidget {
  const _CitasView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<CitasBloc, CitasState>(
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  const SectionHeader(
                    title: 'Citas veterinarias',
                    subtitle: 'Agenda de visitas programadas',
                    showBack: true,
                  ),
                  Expanded(
                    child: switch (state.status) {
                      CitasStatus.initial || CitasStatus.loading => const AppLoading(),
                      CitasStatus.error => Center(child: Text(state.error ?? 'Error')),
                      CitasStatus.loaded => state.items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 64, color: cs.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                  Text('No hay citas programadas', style: TextStyle(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async => context.read<CitasBloc>().add(const CitasRefreshed()),
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                                itemCount: state.items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final cita = state.items[i];
                                  final color = switch (cita.estado) {
                                    EstadoCita.pendiente => cs.tertiary,
                                    EstadoCita.completada => cs.primary,
                                    EstadoCita.cancelada => cs.error,
                                  };
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border(left: BorderSide(color: color, width: 4)),
                                    ),
                                    child: ListTile(
                                      title: Text(cita.tipo.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(cita.veterinario?.nombre ?? 'Sin veterinario'),
                                          Text(
                                            '${cita.fechaHora.day}/${cita.fechaHora.month}/${cita.fechaHora.year} ${cita.fechaHora.hour}:${cita.fechaHora.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(cita.estado.label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
                                      ),
                                      onTap: () => context.push('/health/citas/${cita.id}'),
                                    ),
                                  );
                                },
                              ),
                            ),
                    },
                  ),
                ],
              ),
              Positioned(
                bottom: 24,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () async {
                    await context.push('/health/citas/new');
                    if (context.mounted) {
                      context.read<CitasBloc>().add(const CitasRefreshed());
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}