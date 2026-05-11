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
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../bloc/animales_list_bloc.dart';

class AnimalesListPage extends StatelessWidget {
  const AnimalesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lee la finca activa del selector global y la propaga al bloc.
    // Si la finca no cambió respecto a la última carga, el handler hace no-op.
    final fincaId = context.read<FincasListBloc>().state.selectedFincaId;
    final bloc = getIt<AnimalesListBloc>()
      ..add(AnimalesListFincaFilterChanged(fincaId: fincaId));
    return BlocProvider<AnimalesListBloc>.value(
      value: bloc,
      child: const _AnimalesListView(),
    );
  }
}

class _AnimalesListView extends StatefulWidget {
  const _AnimalesListView();
  @override
  State<_AnimalesListView> createState() => _AnimalesListViewState();
}

class _AnimalesListViewState extends State<_AnimalesListView> {
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
          .read<AnimalesListBloc>()
          .add(const AnimalesListNextPageRequested());
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
            title: t.animalsTitle,
            subtitle: t.animalsSubtitle,
            showBack: true,
            trailing: _AddButton(
              onTap: () => context.push('/inventory/animales/new'),
            ),
          ),
          _FilterBar(),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<AnimalesListBloc, AnimalesListState>(
              builder: (context, state) {
                return switch (state.status) {
                  AnimalesListStatus.initial ||
                  AnimalesListStatus.loading =>
                    const AppLoading(),
                  AnimalesListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<AnimalesListBloc>()
                          .add(const AnimalesListRefreshed()),
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

  Widget _buildList(BuildContext context, AnimalesListState state) {
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
                PhosphorIcons.cow(PhosphorIconsStyle.duotone),
                color: cs.primary,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(t.noAnimals,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  )),
              const SizedBox(height: 6),
              Text(t.createFirstAnimal,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<AnimalesListBloc>().add(const AnimalesListRefreshed());
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
          final a = state.items[index];
          return EntityListCard(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: a.estado == AnimalEstado.activo
                    ? cs.primary.withValues(alpha: 0.12)
                    : cs.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PhosphorIcon(
                PhosphorIcons.cow(PhosphorIconsStyle.fill),
                color: a.estado == AnimalEstado.activo
                    ? cs.primary
                    : cs.onSurfaceVariant,
                size: 26,
              ),
            ),
            title: a.numeroIdentificacion,
            subtitle: '${a.raza} • ${a.peso.toStringAsFixed(0)} kg',
            chips: [
              EntityChipData(label: a.genero.label),
              EntityChipData(
                label: a.estado.label,
                color: a.estado == AnimalEstado.activo
                    ? cs.primary
                    : cs.onSurfaceVariant,
              ),
              if (a.potreroId != null)
                EntityChipData(label: a.potreroId!, color: cs.primary),
            ],
            onTap: () => context.push('/inventory/animales/${a.id}'),
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

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return BlocBuilder<AnimalesListBloc, AnimalesListState>(
      buildWhen: (a, b) => a.filter != b.filter,
      builder: (context, state) {
        return SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _FilterChip(
                label: t.allFilter,
                active: state.filter.estado == null && state.filter.genero == null,
                onTap: () => context
                    .read<AnimalesListBloc>()
                    .add(const AnimalesListFilterChanged(AnimalFilter())),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: t.activeFilter,
                active: state.filter.estado == AnimalEstado.activo,
                onTap: () => context.read<AnimalesListBloc>().add(
                      AnimalesListFilterChanged(
                          state.filter.copyWith(estado: AnimalEstado.activo)),
                    ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: t.soldFilter,
                active: state.filter.estado == AnimalEstado.vendido,
                onTap: () => context.read<AnimalesListBloc>().add(
                      AnimalesListFilterChanged(
                          state.filter.copyWith(estado: AnimalEstado.vendido)),
                    ),
              ),
              const SizedBox(width: 14),
              _FilterChip(
                label: t.maleFilter,
                active: state.filter.genero == AnimalGenero.macho,
                onTap: () => context.read<AnimalesListBloc>().add(
                      AnimalesListFilterChanged(
                          state.filter.copyWith(genero: AnimalGenero.macho)),
                    ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: t.femaleFilter,
                active: state.filter.genero == AnimalGenero.hembra,
                onTap: () => context.read<AnimalesListBloc>().add(
                      AnimalesListFilterChanged(
                          state.filter.copyWith(genero: AnimalGenero.hembra)),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
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
