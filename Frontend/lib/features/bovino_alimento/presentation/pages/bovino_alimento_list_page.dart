import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_squircle_fab.dart';
import '../../../../core/widgets/entity_list_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../bloc/bovino_alimento_bloc.dart';
import '../widgets/bovino_alimento_form_sheet.dart';

class BovinoAlimentoListPage extends StatelessWidget {
  final int animalId;
  const BovinoAlimentoListPage({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BovinoAlimentoBloc>(
      create: (_) => getIt<BovinoAlimentoBloc>()
        ..add(BovinoAlimentoLoadByAnimal(animalId)),
      child: _BovinoAlimentoListView(animalId: animalId),
    );
  }
}

class _BovinoAlimentoListView extends StatelessWidget {
  final int animalId;
  const _BovinoAlimentoListView({required this.animalId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              const SectionHeader(
                title: 'Alimentación',
                subtitle: 'Historial de consumos del animal',
                showBack: true,
              ),
              Expanded(
                child: BlocBuilder<BovinoAlimentoBloc, BovinoAlimentoState>(
                  builder: (context, state) {
                    return switch (state.status) {
                      BovinoAlimentoStatus.initial ||
                      BovinoAlimentoStatus.loading =>
                        const AppLoading(),
                      BovinoAlimentoStatus.error => AppErrorView(
                          failure: state.failure!,
                          onRetry: () => context
                              .read<BovinoAlimentoBloc>()
                              .add(BovinoAlimentoLoadByAnimal(animalId)),
                        ),
                      _ => state.items.isEmpty
                          ? _Empty(cs: cs)
                          : _List(animalId: animalId, state: state, cs: cs),
                    };
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 24,
            child: Builder(
              builder: (innerCtx) => AppSquircleFab(
                onPressed: () => _openFormSheet(innerCtx),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFormSheet(BuildContext context) {
    final bloc = context.read<BovinoAlimentoBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<BovinoAlimentoBloc>.value(
        value: bloc,
        child: BovinoAlimentoFormSheet(animalId: animalId),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final ColorScheme cs;
  const _Empty({required this.cs});

  @override
  Widget build(BuildContext context) {
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
              'Sin registros de alimentación',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Aún no se han asignado alimentos a este animal.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final int animalId;
  final BovinoAlimentoState state;
  final ColorScheme cs;
  const _List({
    required this.animalId,
    required this.state,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'es_CO');
    final moneyFmt =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final qtyFmt = NumberFormat.decimalPattern('es_CO');
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context
            .read<BovinoAlimentoBloc>()
            .add(BovinoAlimentoLoadByAnimal(animalId));
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = state.items[i];
          final title = (item.alimentoNombre != null &&
                  item.alimentoNombre!.isNotEmpty)
              ? item.alimentoNombre!
              : item.alimentoId;
          final chips = <EntityChipData>[
            EntityChipData(label: '${qtyFmt.format(item.cantidad)} kg'),
            if (item.alimentoCosto != null)
              EntityChipData(
                label: moneyFmt.format(item.alimentoCosto),
                color: cs.secondary,
              ),
          ];
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
            title: title,
            subtitle: dateFmt.format(item.fecha),
            chips: chips,
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error),
              onPressed: () => _confirmRemove(context, item.animalId,
                  item.alimentoId, title),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    int animalId,
    String alimentoId,
    String nombre,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eliminar asignación'),
        content: Text('¿Eliminar el registro de "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<BovinoAlimentoBloc>().add(
            BovinoAlimentoRemoved(
              animalId: animalId,
              alimentoId: alimentoId,
            ),
          );
    }
  }
}
