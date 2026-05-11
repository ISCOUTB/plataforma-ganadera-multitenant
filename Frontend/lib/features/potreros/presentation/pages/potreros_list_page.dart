import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/entity_list_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../fincas/presentation/bloc/fincas_list_bloc.dart';
import '../bloc/potreros_list_bloc.dart';

class PotrerosListPage extends StatelessWidget {
  const PotrerosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fincaId = context.read<FincasListBloc>().state.selectedFincaId;
    final bloc = getIt<PotrerosListBloc>()
      ..add(PotrerosListFincaFilterChanged(fincaId: fincaId));
    return BlocProvider<PotrerosListBloc>.value(
      value: bloc,
      child: const _PotrerosListView(),
    );
  }
}

class _PotrerosListView extends StatefulWidget {
  const _PotrerosListView();
  @override
  State<_PotrerosListView> createState() => _PotrerosListViewState();
}

class _PotrerosListViewState extends State<_PotrerosListView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context
          .read<PotrerosListBloc>()
          .add(const PotrerosListNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = S.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SectionHeader(
            title: t.paddocksTitle,
            subtitle: t.paddocksSubtitle,
            showBack: true,
            trailing: Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/inventory/potreros/new'),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PotrerosListBloc, PotrerosListState>(
              builder: (context, state) {
                return switch (state.status) {
                  PotrerosListStatus.initial ||
                  PotrerosListStatus.loading =>
                    const AppLoading(),
                  PotrerosListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<PotrerosListBloc>()
                          .add(const PotrerosListRefreshed()),
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

  Widget _buildList(BuildContext context, PotrerosListState state) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final t = S.of(context);
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.plant(PhosphorIconsStyle.duotone),
                color: cs.primary,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                t.noPaddocks,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.createFirstPaddock,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<PotrerosListBloc>().add(const PotrerosListRefreshed());
      },
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: AppLoading(),
            );
          }
          final p = state.items[index];
          return EntityListCard(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PhosphorIcon(
                PhosphorIcons.plant(PhosphorIconsStyle.fill),
                color: cs.primary,
                size: 24,
              ),
            ),
            title: p.nombre,
            subtitle: p.fincaId != null ? 'Finca: ${p.fincaId}' : 'Sin finca',
            chips: [
              EntityChipData(label: '${p.capacidadAnimales} cap.'),
              if (p.area != null)
                EntityChipData(
                  label: '${p.area!.toStringAsFixed(0)} ha',
                  color: cs.primary,
                ),
              if (p.estado != null)
                EntityChipData(
                  label: p.estado!,
                  color: p.estado == 'activo'
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
            ],
            onTap: () => context.push('/inventory/potreros/${p.id}'),
          );
        },
      ),
    );
  }
}
