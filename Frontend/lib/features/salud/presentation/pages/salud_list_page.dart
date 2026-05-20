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
import '../../domain/entities/salud.dart';
import '../bloc/salud_list_bloc.dart';

class SaludListPage extends StatelessWidget {
  const SaludListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fincaId = context.read<FincasListBloc>().state.selectedFincaId;
    final bloc = getIt<SaludListBloc>()
      ..add(SaludListFincaFilterChanged(fincaId: fincaId));
    return BlocProvider<SaludListBloc>.value(
      value: bloc,
      child: const _SaludListView(),
    );
  }
}

class _SaludListView extends StatefulWidget {
  const _SaludListView();
  @override
  State<_SaludListView> createState() => _SaludListViewState();
}

class _SaludListViewState extends State<_SaludListView> {
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
      context.read<SaludListBloc>().add(const SaludListNextPageRequested());
    }
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
            title: t.healthListTitle,
            subtitle: t.healthListSubtitle,
            showBack: true,
            trailing: Material(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/health/salud/new'),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SaludListBloc, SaludListState>(
              builder: (context, state) {
                return switch (state.status) {
                  SaludListStatus.initial ||
                  SaludListStatus.loading =>
                    const AppLoading(),
                  SaludListStatus.error => AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<SaludListBloc>()
                          .add(const SaludListRefreshed()),
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

  Widget _buildList(BuildContext context, SaludListState state) {
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
                PhosphorIcons.firstAidKit(PhosphorIconsStyle.duotone),
                color: cs.primary,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                t.noHealthRecords,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                t.registerHealthRecord,
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
        context.read<SaludListBloc>().add(const SaludListRefreshed());
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
          final s = state.items[index];
          final dateFmt = s.fechaAplicacion != null
              ? DateFormat.yMMMd('es').format(s.fechaAplicacion!)
              : '—';
          return EntityListCard(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(s.tipoIntervencion),
                color: cs.primary,
                size: 24,
              ),
            ),
            title: s.tipoIntervencion.label,
            subtitle: s.productoAplicado ?? s.descripcionEnfermedad ?? '—',
            chips: [
              EntityChipData(label: dateFmt, color: cs.onSurfaceVariant),
              if (s.animalId != null)
                EntityChipData(
                  label: 'Bov #${s.animalId}',
                  color: cs.secondary,
                ),
            ],
            onTap: () => context.push('/health/salud/${s.id}'),
          );
        },
      ),
    );
  }

  IconData _iconFor(TipoIntervencion t) => switch (t) {
        TipoIntervencion.vacunacion => Icons.vaccines_rounded,
        TipoIntervencion.vitaminas => Icons.local_pharmacy_rounded,
        TipoIntervencion.desparasitacion => Icons.bug_report_rounded,
        TipoIntervencion.enfermedad => Icons.healing_rounded,
      };
}
