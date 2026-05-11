import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../bloc/finca_detail_bloc.dart';

class FincaDetailPage extends StatelessWidget {
  final String fincaId;
  const FincaDetailPage({super.key, required this.fincaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FincaDetailBloc>(
      create: (_) =>
          getIt<FincaDetailBloc>()..add(FincaDetailLoaded(fincaId)),
      child: _FincaDetailView(fincaId: fincaId),
    );
  }
}

class _FincaDetailView extends StatelessWidget {
  final String fincaId;
  const _FincaDetailView({required this.fincaId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<FincaDetailBloc, FincaDetailState>(
        listener: (context, state) {
          final t = S.of(context);
          if (state.status == FincaDetailStatus.deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.farmDeleted),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/inventory/fincas');
          }
          if (state.status == FincaDetailStatus.error && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FincaDetailStatus.loading ||
              state.status == FincaDetailStatus.initial) {
            return const AppLoading();
          }
          if (state.finca == null && state.failure != null) {
            return AppErrorView(
              failure: state.failure!,
              onRetry: () =>
                  context.read<FincaDetailBloc>().add(FincaDetailLoaded(fincaId)),
            );
          }
          final t = S.of(context);
          final finca = state.finca!;
          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              SectionHeader(
                title: finca.nombre,
                subtitle: finca.id,
                showBack: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBtn(
                      icon: Icons.edit_outlined,
                      onTap: () =>
                          context.push('/inventory/fincas/${finca.id}/edit'),
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.delete_outline,
                      color: cs.error,
                      onTap: () => _confirmDelete(context),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row(
                        icon: PhosphorIcons.mapPin(PhosphorIconsStyle.bold),
                        label: t.location,
                        value: finca.ubicacion ?? '—',
                      ),
                      const Divider(height: 24),
                      _Row(
                        icon: PhosphorIcons.user(PhosphorIconsStyle.bold),
                        label: t.owner,
                        value: finca.propietario ?? '—',
                      ),
                      const Divider(height: 24),
                      _Row(
                        icon: PhosphorIcons.ruler(PhosphorIconsStyle.bold),
                        label: t.totalArea,
                        value: finca.areaTotal != null
                            ? '${finca.areaTotal} ha'
                            : '—',
                      ),
                      const Divider(height: 24),
                      _Row(
                        icon: PhosphorIcons.calendar(PhosphorIconsStyle.bold),
                        label: t.registered,
                        value: finca.fechaRegistro != null
                            ? finca.fechaRegistro!
                                .toIso8601String()
                                .substring(0, 10)
                            : '—',
                      ),
                    ],
                  ),
                ),
              ),
              // Sub-listas: animales y potreros de esta finca.
              if (state.animales.isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'ANIMALES (${state.animales.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final a in state.animales.take(10))
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${a.numeroIdentificacion} · ${a.raza}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '${a.peso.toStringAsFixed(0)} kg',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              if (state.potreros.isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'POTREROS (${state.potreros.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final p in state.potreros)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${p.nombre} (${p.id})',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '${p.capacidadAnimales} cap.',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteFarm),
        content: Text(t.deleteFarmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<FincaDetailBloc>().add(const FincaDetailDeleted());
    }
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PhosphorIcon(icon, color: cs.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
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
