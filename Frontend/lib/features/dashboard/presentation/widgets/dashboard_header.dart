import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../alertas/domain/entities/alertas_summary.dart';
import '../../../alertas/presentation/bloc/alertas_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../fincas/domain/entities/finca.dart';
import '../../../fincas/presentation/bloc/fincas_list_bloc.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;
    final greetingName = _formatGreetingName(user?.nombre);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              S.of(context).goodMorning(greetingName),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const _NotificationBell(),
          const SizedBox(width: 8),
          const _TenantSelector(),
        ],
      ),
    );
  }

  String _formatGreetingName(String? name) {
    if (name == null || name.isEmpty) return 'Operator';
    return name.split(' ').first;
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider<AlertasBloc>(
      create: (_) => getIt<AlertasBloc>()..add(const AlertasStarted()),
      child: BlocBuilder<AlertasBloc, AlertasState>(
        builder: (context, state) {
          final count = state.status == AlertasStatus.loaded
              ? (state.data?.urgentes ?? 0)
              : 0;
          final bloc = context.read<AlertasBloc>();

          return GestureDetector(
            onTap: () => _openNotificationsPanel(context, bloc),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.bell(PhosphorIconsStyle.bold),
                    color: count > 0 ? cs.error : cs.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cs.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openNotificationsPanel(BuildContext context, AlertasBloc bloc) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _NotificationsSheet(
          onNavigate: (route) {
            Navigator.of(context).pop();
            context.push(route);
          },
        ),
      ),
    );
  }
}

class _NotificationsSheet extends StatefulWidget {
  final void Function(String route) onNavigate;

  const _NotificationsSheet({required this.onNavigate});

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  String _filtro = 'todos';
  bool _ordenReciente = true;

  static const _filtros = [
    ('todos', 'Todos'),
    ('salud', 'Salud'),
    ('reproduccion', 'Reproducción'),
  ];

  List<AlertaPrioritaria> _filtradas(List<AlertaPrioritaria> alertas) {
    var result = alertas.where((a) {
      if (_filtro == 'todos') return true;
      if (_filtro == 'salud') {
        return a.tipo.contains('salud') ||
            a.tipo.contains('vacun') ||
            a.tipo.contains('despar') ||
            a.tipo.contains('enferm') ||
            a.tipo.contains('vitamin');
      }
      if (_filtro == 'reproduccion') {
        return a.tipo.contains('repro') ||
            a.tipo.contains('parto') ||
            a.tipo.contains('celo');
      }
      return true;
    }).toList();

    result.sort((a, b) {
      final fa = a.fecha;
      final fb = b.fecha;
      if (fa == null && fb == null) return 0;
      if (fa == null) return 1;
      if (fb == null) return -1;
      return _ordenReciente ? fb.compareTo(fa) : fa.compareTo(fb);
    });

    return result;
  }

  String _routeForAlerta(AlertaPrioritaria alerta) {
    final tipo = alerta.tipo.toLowerCase();
    if (tipo.contains('repro') ||
        tipo.contains('parto') ||
        tipo.contains('celo')) {
      return '/health/reproduccion';
    }
    return '/health/salud';
  }

  String _fechaLabel(DateTime? fecha) {
    if (fecha == null) return '';
    final hoy = DateTime.now();
    final diff = fecha.difference(hoy).inDays;
    if (diff < 0) return 'Vencida hace ${diff.abs()} día(s)';
    if (diff == 0) return 'Vence hoy';
    return 'Vence en $diff día(s)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<AlertasBloc, AlertasState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold),
                              color: cs.primary, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Notificaciones',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          if (state.status == AlertasStatus.loaded &&
                              state.data != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${state.data!.urgentes} urgentes',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.error,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filtros.map((f) {
                            final selected = _filtro == f.$1;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _filtro = f.$1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? cs.primary
                                        : cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    f.$2,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: selected
                                          ? cs.onPrimary
                                          : cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.sort,
                              size: 16, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _ordenReciente = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _ordenReciente
                                    ? cs.primary
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Más recientes',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _ordenReciente
                                      ? cs.onPrimary
                                      : cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _ordenReciente = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: !_ordenReciente
                                    ? cs.primary
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Más antiguas',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: !_ordenReciente
                                      ? cs.onPrimary
                                      : cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: cs.outlineVariant),
                Expanded(
                  child: _buildBody(context, state, scrollController),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AlertasState state,
      ScrollController scrollController) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (state.status == AlertasStatus.loading ||
        state.status == AlertasStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AlertasStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 40),
            const SizedBox(height: 12),
            Text(
              'No se pudieron cargar las alertas',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context
                  .read<AlertasBloc>()
                  .add(const AlertasRefreshed()),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final data = state.data;
    final alertas = data == null
        ? <AlertaPrioritaria>[]
        : _filtradas(data.alertasPriorizadas);

    if (alertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
                color: cs.primary, size: 48),
            const SizedBox(height: 12),
            Text(
              'Todo bajo control',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No hay alertas en esta categoría',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      itemCount: alertas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final alerta = alertas[i];
        final color = switch (alerta.severity) {
          AlertaSeverity.high => cs.error,
          AlertaSeverity.medium => cs.tertiary,
          AlertaSeverity.low => cs.primary,
        };
        final fechaLabel = _fechaLabel(alerta.fecha);
        return GestureDetector(
          onTap: () => widget.onNavigate(_routeForAlerta(alerta)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: color, width: 4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alerta.tipo.replaceAll('_', ' ').toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _describe(alerta.detalle),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fechaLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          fechaLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        alerta.severity.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: cs.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _describe(Map<String, dynamic> detalle) {
    return detalle['producto_aplicado']?.toString() ??
        detalle['descripcion_enfermedad']?.toString() ??
        detalle['tipo_intervencion']?.toString() ??
        detalle['pk_id_reproduccion']?.toString() ??
        'Sin detalle';
  }
}

class _TenantSelector extends StatelessWidget {
  const _TenantSelector();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FincasListBloc, FincasListState>(
      builder: (context, state) {
        final label = _label(state);
        final enabled = state.items.isNotEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? () => _openFincaPicker(context) : null,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary, width: 2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.secondary, cs.primary],
                  ),
                ),
                child: Icon(
                  Icons.landscape_outlined,
                  color: cs.onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: cs.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        );
      },
    );
  }

  String _label(FincasListState state) {
    if (state.status == FincasListStatus.loading && state.items.isEmpty) {
      return 'Cargando...';
    }
    if (state.status == FincasListStatus.error && state.items.isEmpty) {
      return 'Sin fincas';
    }
    if (state.items.isEmpty) return 'Sin fincas';
    final selected = state.selected;
    if (selected != null) return selected.nombre;
    return 'Todas (${state.items.length})';
  }

  void _openFincaPicker(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bloc = context.read<FincasListBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<FincasListBloc>.value(
        value: bloc,
        child: const _FincaPickerSheet(),
      ),
    );
  }
}

class _FincaPickerSheet extends StatelessWidget {
  const _FincaPickerSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      child: BlocBuilder<FincasListBloc, FincasListState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Selecciona una finca',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (state.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      state.status == FincasListStatus.loading
                          ? 'Cargando fincas...'
                          : 'Sin fincas disponibles.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.items.length + 1,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: cs.outlineVariant,
                      ),
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          final selected = state.selectedFincaId == null;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.public, color: cs.primary),
                            title: Text(
                              'Todas las fincas',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: selected
                                ? Icon(Icons.check, color: cs.primary)
                                : null,
                            onTap: () {
                              context
                                  .read<FincasListBloc>()
                                  .add(const FincaSelected(fincaId: null));
                              Navigator.of(context).pop();
                            },
                          );
                        }
                        final Finca f = state.items[i - 1];
                        final selected = state.selectedFincaId == f.id;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.landscape_outlined,
                              color: cs.primary),
                          title: Text(
                            f.nombre,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: f.ubicacion != null
                              ? Text(f.ubicacion!)
                              : null,
                          trailing: selected
                              ? Icon(Icons.check, color: cs.primary)
                              : null,
                          onTap: () {
                            context
                                .read<FincasListBloc>()
                                .add(FincaSelected(fincaId: f.id));
                            Navigator.of(context).pop(f);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}