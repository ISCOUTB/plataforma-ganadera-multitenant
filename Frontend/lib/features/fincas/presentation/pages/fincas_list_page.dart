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
import '../bloc/fincas_list_bloc.dart';

class FincasListPage extends StatelessWidget {
  const FincasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<FincasListBloc>()..add(const FincasListStarted());
    return BlocProvider<FincasListBloc>.value(
      value: bloc,
      child: const _FincasListView(),
    );
  }
}

class _FincasListView extends StatefulWidget {
  const _FincasListView();
  @override
  State<_FincasListView> createState() => _FincasListViewState();
}

class _FincasListViewState extends State<_FincasListView> {
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
      context.read<FincasListBloc>().add(const FincasListNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SectionHeader(
            title: t.farmsTitle,
            subtitle: t.farmsSubtitle,
            showBack: true,
            trailing: _AddButton(
              onTap: () => context.push('/inventory/fincas/new'),
            ),
          ),
          Expanded(
            child: BlocBuilder<FincasListBloc, FincasListState>(
              builder: (context, state) {
                return switch (state.status) {
                  FincasListStatus.initial ||
                  FincasListStatus.loading =>
                    const AppLoading(),
                  FincasListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<FincasListBloc>()
                          .add(const FincasListRefreshed()),
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

  Widget _buildList(BuildContext context, FincasListState state) {
    final cs = Theme.of(context).colorScheme;
    if (state.items.isEmpty) {
      return const _EmptyState();
    }
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<FincasListBloc>().add(const FincasListRefreshed());
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
          final finca = state.items[index];
          return EntityListCard(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PhosphorIcon(
                PhosphorIcons.barn(PhosphorIconsStyle.fill),
                color: cs.primary,
                size: 24,
              ),
            ),
            title: finca.nombre,
            subtitle: finca.ubicacion ?? 'Sin ubicación',
            chips: [
              EntityChipData(label: finca.id),
              if (finca.areaTotal != null)
                EntityChipData(
                  label: '${finca.areaTotal!.toStringAsFixed(0)} ha',
                  color: cs.primary,
                ),
            ],
            onTap: () => context.push('/inventory/fincas/${finca.id}'),
          );
        },
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.add, color: cs.onPrimary, size: 24),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final t = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(
                PhosphorIcons.barn(PhosphorIconsStyle.duotone),
                color: cs.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.noFarms,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.createFirstFarm,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
