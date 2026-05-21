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
import '../bloc/alimentos_list_bloc.dart';

class AlimentosListPage extends StatelessWidget {
  const AlimentosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<AlimentosListBloc>()..add(const AlimentosListStarted());
    return BlocProvider<AlimentosListBloc>.value(
      value: bloc,
      child: const _AlimentosListView(),
    );
  }
}

class _AlimentosListView extends StatelessWidget {
  const _AlimentosListView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SectionHeader(
            title: S.of(context).foodTitle,
            subtitle: S.of(context).foodSubtitle,
            showBack: true,
            trailing: Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/money/alimentos/new'),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AlimentosListBloc, AlimentosListState>(
              builder: (context, state) {
                return switch (state.status) {
                  AlimentosListStatus.initial ||
                  AlimentosListStatus.loading =>
                    const AppLoading(),
                  AlimentosListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<AlimentosListBloc>()
                          .add(const AlimentosListRefreshed()),
                    ),
                  _ => state.items.isEmpty
                      ? Center(
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
                                  S.of(context).noFood,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: cs.primary,
                          onRefresh: () async {
                            context
                                .read<AlimentosListBloc>()
                                .add(const AlimentosListRefreshed());
                          },
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: state.items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final a = state.items[i];
                              return EntityListCard(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: PhosphorIcon(
                                    PhosphorIcons.plant(
                                        PhosphorIconsStyle.fill),
                                    color: cs.primary,
                                    size: 24,
                                  ),
                                ),
                                title: a.tipoAlimento,
                                subtitle: a.frecuencia ?? '—',
                                chips: [
                                  EntityChipData(label: a.id),
                                  if (a.costo != null)
                                    EntityChipData(
                                      label: fmt.format(a.costo),
                                      color: cs.secondary,
                                    ),
                                ],
                                onTap: () =>
                                    context.push('/money/alimentos/${a.id}/detalle?nombre=${Uri.encodeComponent(a.tipoAlimento)}'),
                              );
                            },
                          ),
                        ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
