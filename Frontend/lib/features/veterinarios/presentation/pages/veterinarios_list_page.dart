import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../bloc/veterinarios_bloc.dart';

class VeterinariosListPage extends StatelessWidget {
  const VeterinariosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VeterinariosBloc>(
      create: (_) => getIt<VeterinariosBloc>()..add(const VeterinariosStarted()),
      child: const _VeterinariosView(),
    );
  }
}

class _VeterinariosView extends StatelessWidget {
  const _VeterinariosView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<VeterinariosBloc, VeterinariosState>(
        builder: (context, state) {
          return Column(
            children: [
              const SectionHeader(
                title: 'Veterinarios',
                subtitle: 'Contactos externos registrados',
                showBack: true,
              ),
              Expanded(
                child: switch (state.status) {
                  VeterinariosStatus.initial ||
                  VeterinariosStatus.loading => const AppLoading(),
                  VeterinariosStatus.error => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: cs.error, size: 48),
                          const SizedBox(height: 12),
                          Text(state.error ?? 'Error', style: TextStyle(color: cs.error)),
                          TextButton(
                            onPressed: () => context.read<VeterinariosBloc>().add(const VeterinariosRefreshed()),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  VeterinariosStatus.loaded => state.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIcons.stethoscope(PhosphorIconsStyle.bold), size: 64, color: cs.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text('No hay veterinarios registrados', style: TextStyle(color: cs.onSurfaceVariant)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => context.read<VeterinariosBloc>().add(const VeterinariosRefreshed()),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                            itemCount: state.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final vet = state.items[i];
                              return Container(
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                                    child: Icon(PhosphorIcons.stethoscope(PhosphorIconsStyle.bold), color: cs.primary, size: 20),
                                  ),
                                  title: Text(vet.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: vet.especialidad != null ? Text(vet.especialidad!) : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (vet.telefono != null)
                                        Icon(Icons.phone_outlined, color: cs.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                                    ],
                                  ),
                                  onTap: () => context.push('/health/veterinarios/${vet.id}'),
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
