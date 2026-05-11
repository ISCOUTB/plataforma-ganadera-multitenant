import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../fincas/domain/entities/finca.dart';
import '../../../fincas/presentation/bloc/fincas_list_bloc.dart';

/// Cabecera del Dashboard.
/// - Saludo personalizado con el nombre del usuario autenticado.
/// - Selector de finca: muestra la finca activa y abre una hoja con la lista.
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
                      // +1 por el item virtual "Todas las fincas".
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
