import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/entity_list_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../fincas/presentation/bloc/fincas_list_bloc.dart';
import '../../domain/entities/finanza.dart';
import '../bloc/finanzas_list_bloc.dart';
import '../bloc/finanzas_resumen_bloc.dart';

class FinanzasListPage extends StatelessWidget {
  const FinanzasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fincaId = context.read<FincasListBloc>().state.selectedFincaId;
    final listBloc = getIt<FinanzasListBloc>()
      ..add(FinanzasListFincaFilterChanged(fincaId: fincaId));
    final resumenBloc = getIt<FinanzasResumenBloc>()
      ..add(FinanzasResumenFincaFilterChanged(fincaId: fincaId));
    return MultiBlocProvider(
      providers: [
        BlocProvider<FinanzasListBloc>.value(value: listBloc),
        BlocProvider<FinanzasResumenBloc>.value(value: resumenBloc),
      ],
      child: const _FinanzasListView(),
    );
  }
}

class _FinanzasListView extends StatefulWidget {
  const _FinanzasListView();
  @override
  State<_FinanzasListView> createState() => _FinanzasListViewState();
}

class _FinanzasListViewState extends State<_FinanzasListView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context
            .read<FinanzasListBloc>()
            .add(const FinanzasListNextPageRequested());
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SectionHeader(
            title: S.of(context).financesTitle,
            subtitle: S.of(context).financesSubtitle,
            showBack: true,
            trailing: Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/money/finanzas/new'),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                ),
              ),
            ),
          ),
          const _ResumenCard(),
          const _FilterBar(),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<FinanzasListBloc, FinanzasListState>(
              builder: (context, state) {
                return switch (state.status) {
                  FinanzasListStatus.initial ||
                  FinanzasListStatus.loading =>
                    const AppLoading(),
                  FinanzasListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<FinanzasListBloc>()
                          .add(const FinanzasListRefreshed()),
                    ),
                  _ => _buildList(context, state),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, FinanzasListState state) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
                color: cs.primary,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                t.noFinances,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<FinanzasListBloc>().add(const FinanzasListRefreshed());
        context.read<FinanzasResumenBloc>().add(const FinanzasResumenStarted());
      },
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: AppLoading(),
            );
          }
          final f = state.items[index];
          final isIngreso = f.tipoMovimiento == TipoMovimiento.ingreso;
          final color = isIngreso ? cs.primary : cs.error;
          final fechaLabel = f.fecha != null
              ? DateFormat.yMMMd('es').format(f.fecha!)
              : '—';
          return EntityListCard(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: 24,
              ),
            ),
            title: f.concepto,
            subtitle: '${f.categoria ?? '—'} · $fechaLabel',
            chips: [
              EntityChipData(
                label: '${isIngreso ? '+' : '-'} ${fmt.format(f.monto)}',
                color: color,
              ),
            ],
            onTap: () => context.push('/money/finanzas/${f.id}'),
          );
        },
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard();

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return BlocBuilder<FinanzasResumenBloc, FinanzasResumenState>(
      builder: (context, state) {
        final data = state.data;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _Stat(
                  label: t.income,
                  value: data != null ? fmt.format(data.totalIngresos) : '—',
                  color: cs.primary,
                ),
                Container(
                    width: 1, height: 40, color: cs.outline),
                _Stat(
                  label: t.expenses,
                  value: data != null ? fmt.format(data.totalGastos) : '—',
                  color: cs.error,
                ),
                Container(
                    width: 1, height: 40, color: cs.outline),
                _Stat(
                  label: t.balance,
                  value: data != null ? fmt.format(data.balance) : '—',
                  color: cs.onSurface,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return BlocBuilder<FinanzasListBloc, FinanzasListState>(
      buildWhen: (a, b) => a.filter != b.filter,
      builder: (context, state) {
        return SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _Chip(
                label: t.allFilter,
                active: state.filter == null,
                onTap: () => context
                    .read<FinanzasListBloc>()
                    .add(const FinanzasListFilterChanged()),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: t.income,
                active: state.filter == TipoMovimiento.ingreso,
                onTap: () => context.read<FinanzasListBloc>().add(
                      const FinanzasListFilterChanged(
                          tipo: TipoMovimiento.ingreso),
                    ),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: t.expenses,
                active: state.filter == TipoMovimiento.gasto,
                onTap: () => context.read<FinanzasListBloc>().add(
                      const FinanzasListFilterChanged(
                          tipo: TipoMovimiento.gasto),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? cs.primary : cs.outline,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
