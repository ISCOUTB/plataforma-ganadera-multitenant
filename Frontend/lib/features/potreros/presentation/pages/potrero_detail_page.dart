import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/finca_rotation_guard.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/potrero.dart';
import '../bloc/potrero_detail_bloc.dart';

class PotreroDetailPage extends StatelessWidget {
  final String potreroId;
  const PotreroDetailPage({super.key, required this.potreroId});

  @override
  Widget build(BuildContext context) {
    return FincaRotationGuard(
      fallbackRoute: RoutePaths.inventory,
      child: BlocProvider<PotreroDetailBloc>(
        create: (_) =>
            getIt<PotreroDetailBloc>()..add(PotreroDetailLoaded(potreroId)),
        child: _PotreroDetailView(potreroId: potreroId),
      ),
    );
  }
}

class _PotreroDetailView extends StatelessWidget {
  final String potreroId;
  const _PotreroDetailView({required this.potreroId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<PotreroDetailBloc, PotreroDetailState>(
        listener: (context, state) {
          if (state.status == PotreroDetailStatus.deleted) {
            final t = S.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.paddockDeleted),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/inventory/potreros');
          }
          if (state.status == PotreroDetailStatus.error && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PotreroDetailStatus.initial ||
              state.status == PotreroDetailStatus.loading) {
            return const AppLoading();
          }
          if (state.potrero == null && state.failure != null) {
            return AppErrorView(
              failure: state.failure!,
              onRetry: () => context
                  .read<PotreroDetailBloc>()
                  .add(PotreroDetailLoaded(potreroId)),
            );
          }
          final p = state.potrero!;
          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              SectionHeader(
                title: p.nombre,
                subtitle: p.id,
                showBack: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBtn(
                      icon: Icons.edit_outlined,
                      onTap: () =>
                          context.push('/inventory/potreros/${p.id}/edit'),
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
              if (state.ocupacion != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _OcupacionCard(ocupacion: state.ocupacion!),
                ),
              const SizedBox(height: 16),
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
                        icon: PhosphorIcons.barn(PhosphorIconsStyle.bold),
                        label: S.of(context).farm,
                        value: p.fincaId ?? '—',
                      ),
                      const Divider(height: 24),
                      _Row(
                        icon: PhosphorIcons.ruler(PhosphorIconsStyle.bold),
                        label: S.of(context).area,
                        value: p.area != null ? '${p.area} ha' : '—',
                      ),
                      const Divider(height: 24),
                      _Row(
                        icon: PhosphorIcons.users(PhosphorIconsStyle.bold),
                        label: S.of(context).capacity,
                        value: '${p.capacidadAnimales} animales',
                      ),
                      const Divider(height: 24),
                      _Row(
                        icon: PhosphorIcons.checkCircle(
                            PhosphorIconsStyle.bold),
                        label: S.of(context).status,
                        value: p.estado ?? '—',
                      ),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deletePaddock),
        content: Text(t.deletePaddockMessage),
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
      context.read<PotreroDetailBloc>().add(const PotreroDetailDeleted());
    }
  }
}

class _OcupacionCard extends StatelessWidget {
  final PotreroOcupacion ocupacion;
  const _OcupacionCard({required this.ocupacion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = S.of(context);
    final color = ocupacion.porcentaje >= 90
        ? cs.error
        : ocupacion.porcentaje >= 70
            ? const Color(0xFFF59E0B)
            : cs.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.occupancy,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ocupacion.actual}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '/ ${ocupacion.capacidad}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${ocupacion.porcentaje}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (ocupacion.porcentaje / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: cs.outline.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estado: ${ocupacion.estado}',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
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
