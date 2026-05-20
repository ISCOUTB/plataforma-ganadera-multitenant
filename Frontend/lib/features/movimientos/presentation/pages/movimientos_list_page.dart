import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/entity_list_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../bloc/movimientos_list_bloc.dart';

class MovimientosListPage extends StatelessWidget {
  const MovimientosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<MovimientosListBloc>()
      ..add(const MovimientosListStarted());
    return BlocProvider<MovimientosListBloc>.value(
      value: bloc,
      child: const _MovimientosListView(),
    );
  }
}

class _MovimientosListView extends StatelessWidget {
  const _MovimientosListView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SectionHeader(
            title: S.of(context).movementsTitle,
            subtitle: S.of(context).movementsSubtitle,
            showBack: true,
            trailing: Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/money/movimientos/new'),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MovimientosListBloc, MovimientosListState>(
              builder: (context, state) {
                return switch (state.status) {
                  MovimientosListStatus.initial ||
                  MovimientosListStatus.loading =>
                    const AppLoading(),
                  MovimientosListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<MovimientosListBloc>()
                          .add(const MovimientosListRefreshed()),
                    ),
                  _ => state.items.isEmpty
                      ? _empty(context, cs)
                      : _buildList(context, state, cs),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, ColorScheme cs) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.duotone),
                color: cs.primary,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context).noMovements,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      );

  Widget _buildList(
    BuildContext context,
    MovimientosListState state,
    ColorScheme cs,
  ) {
    final fmt = DateFormat.yMMMd('es');
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context
            .read<MovimientosListBloc>()
            .add(const MovimientosListRefreshed());
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final m = state.items[i];
          final fechaLabel = m.fecha != null ? fmt.format(m.fecha!) : '—';
          return EntityListCard(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: cs.primary,
                size: 24,
              ),
            ),
            title:
                '${m.potreroOrigen ?? '—'} → ${m.potreroDestino ?? '—'}',
            subtitle: m.motivo ?? S.of(context).noReason,
            chips: [
              EntityChipData(label: fechaLabel, color: cs.onSurfaceVariant),
              if (m.animalId != null)
                EntityChipData(
                    label: 'Bov #${m.animalId}', color: cs.secondary),
            ],
            onTap: () => _showDetail(context, m, cs),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, dynamic m, ColorScheme cs) {
    final t = S.of(context);
    final fmt = DateFormat.yMMMd('es');
    final fechaLabel = m.fecha != null ? fmt.format(m.fecha!) : '—';
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.movementDetail,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            _DetailRow(label: t.origin, value: m.potreroOrigen ?? '—', cs: cs),
            const Divider(height: 20),
            _DetailRow(label: t.destination, value: m.potreroDestino ?? '—', cs: cs),
            const Divider(height: 20),
            _DetailRow(label: t.animal, value: m.animalId != null ? 'Bovino #${m.animalId}' : '—', cs: cs),
            const Divider(height: 20),
            _DetailRow(label: t.date, value: fechaLabel, cs: cs),
            const Divider(height: 20),
            _DetailRow(label: t.reason, value: m.motivo ?? t.noReason, cs: cs),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  const _DetailRow({required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
