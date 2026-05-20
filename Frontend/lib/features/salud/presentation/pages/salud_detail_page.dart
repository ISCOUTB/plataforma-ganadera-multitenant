import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/finca_rotation_guard.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/salud.dart';
import '../bloc/salud_detail_bloc.dart';
import '../bloc/salud_list_bloc.dart';

class SaludDetailPage extends StatelessWidget {
  final int saludId;
  const SaludDetailPage({super.key, required this.saludId});

  @override
  Widget build(BuildContext context) {
    return FincaRotationGuard(
      fallbackRoute: RoutePaths.health,
      child: BlocProvider<SaludDetailBloc>(
        create: (_) =>
            getIt<SaludDetailBloc>()..add(SaludDetailLoaded(saludId)),
        child: _SaludDetailView(saludId: saludId),
      ),
    );
  }
}

class _SaludDetailView extends StatelessWidget {
  final int saludId;
  const _SaludDetailView({required this.saludId});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<SaludDetailBloc, SaludDetailState>(
        listener: (context, state) {
          if (state.status == SaludDetailStatus.deleted) {
            getIt<SaludListBloc>().add(const SaludListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.recordDeleted),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/health/salud');
          }
        },
        builder: (context, state) {
          if (state.status == SaludDetailStatus.initial ||
              state.status == SaludDetailStatus.loading) {
            return const AppLoading();
          }
          if (state.salud == null && state.failure != null) {
            return AppErrorView(
              failure: state.failure!,
              onRetry: () => context
                  .read<SaludDetailBloc>()
                  .add(SaludDetailLoaded(saludId)),
            );
          }
          final s = state.salud!;
          final fmt = DateFormat.yMMMd('es');
          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              SectionHeader(
                title: s.tipoIntervencion.label,
                subtitle: s.productoAplicado ?? '—',
                showBack: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBtn(
                      icon: Icons.edit_outlined,
                      onTap: () =>
                          context.push('/health/salud/${s.id}/edit'),
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.delete_outline,
                      color: cs.error,
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(t.deleteRecord),
                            content: Text(t.deleteRecordMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(t.cancel),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: cs.error),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(t.delete),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          context
                              .read<SaludDetailBloc>()
                              .add(const SaludDetailDeleted());
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _Row(
                          label: t.animal,
                          value: s.animalId != null ? '#${s.animalId}' : '—'),
                      const Divider(height: 24),
                      _Row(label: t.dose, value: s.dosis ?? '—'),
                      const Divider(height: 24),
                      _Row(
                          label: t.applicationDate,
                          value: s.fechaAplicacion != null
                              ? fmt.format(s.fechaAplicacion!)
                              : '—'),
                      const Divider(height: 24),
                      _Row(
                          label: t.nextApplication,
                          value: s.fechaProximaAplicacion != null
                              ? fmt.format(s.fechaProximaAplicacion!)
                              : '—'),
                      const Divider(height: 24),
                      _Row(
                          label: t.cost,
                          value: s.costo != null
                              ? NumberFormat.currency(
                                      locale: 'es_CO',
                                      symbol: '\$',
                                      decimalDigits: 0)
                                  .format(s.costo)
                              : '—'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _IconBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: color ?? cs.onSurface, size: 22),
        ),
      ),
    );
  }
}
