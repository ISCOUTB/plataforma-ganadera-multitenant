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
import '../bloc/reproduccion_list_bloc.dart';

class ReproduccionListPage extends StatelessWidget {
  const ReproduccionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fincaId = context.read<FincasListBloc>().state.selectedFincaId;
    final bloc = getIt<ReproduccionListBloc>()
      ..add(ReproduccionListFincaFilterChanged(fincaId: fincaId));
    return BlocProvider<ReproduccionListBloc>.value(
      value: bloc,
      child: const _ReproduccionListView(),
    );
  }
}

class _ReproduccionListView extends StatefulWidget {
  const _ReproduccionListView();
  @override
  State<_ReproduccionListView> createState() => _ReproduccionListViewState();
}

class _ReproduccionListViewState extends State<_ReproduccionListView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context
            .read<ReproduccionListBloc>()
            .add(const ReproduccionListNextPageRequested());
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
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SectionHeader(
            title: t.reproductionTitle,
            subtitle: t.reproductionSubtitle,
            showBack: true,
            trailing: Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/health/reproduccion/new'),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ReproduccionListBloc, ReproduccionListState>(
              builder: (context, state) {
                return switch (state.status) {
                  ReproduccionListStatus.initial ||
                  ReproduccionListStatus.loading =>
                    const AppLoading(),
                  ReproduccionListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<ReproduccionListBloc>()
                          .add(const ReproduccionListRefreshed()),
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

  Widget _buildList(BuildContext context, ReproduccionListState state) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.heart(PhosphorIconsStyle.duotone),
                color: cs.primary,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                t.noReproductionEvents,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                t.createFirstEvent,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
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
        context
            .read<ReproduccionListBloc>()
            .add(const ReproduccionListRefreshed());
      },
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: AppLoading(),
            );
          }
          final r = state.items[index];
          final parto = r.fechaEstimadoParto != null
              ? DateFormat.yMMMd('es').format(r.fechaEstimadoParto!)
              : '—';
          return EntityListCard(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PhosphorIcon(
                PhosphorIcons.heart(PhosphorIconsStyle.fill),
                color: cs.primary,
                size: 24,
              ),
            ),
            title: r.id,
            subtitle: r.metodoReproduccion ?? '—',
            chips: [
              if (r.prenada)
                EntityChipData(label: t.pregnant, color: cs.primary),
              if (r.enCelo)
                EntityChipData(label: t.inHeat, color: cs.tertiary),
              if (r.fechaEstimadoParto != null)
                EntityChipData(
                    label: 'Parto: $parto', color: cs.onSurfaceVariant),
            ],
            onTap: () => context.push('/health/reproduccion/${r.id}'),
          );
        },
      ),
    );
  }
}
