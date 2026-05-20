import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_squircle_fab.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/usuario_tenant.dart';
import '../bloc/usuarios_bloc.dart';
import '../widgets/usuario_form_sheet.dart';

enum _MutationKind { create, update, delete }

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsuariosBloc>(
      create: (_) => getIt<UsuariosBloc>()..add(const UsuariosStarted()),
      child: const _UsuariosView(),
    );
  }
}

class _UsuariosView extends StatefulWidget {
  const _UsuariosView();

  @override
  State<_UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<_UsuariosView> {
  // Rastrea la última mutación disparada desde esta página. Se consume al
  // recibir `UsuariosStatus.success` para mostrar el SnackBar correcto y
  // cerrar el modal solo si la mutación vino de un form sheet (create/update).
  _MutationKind? _pending;

  void _openFormSheet({UsuarioTenant? user}) {
    final bloc = context.read<UsuariosBloc>();
    _pending = user == null ? _MutationKind.create : _MutationKind.update;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UsuarioFormSheet(bloc: bloc, user: user),
    );
  }

  Future<void> _confirmDelete(UsuarioTenant user) async {
    final l = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(l.confirmDeleteUserMessage(user.nombre)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _pending = _MutationKind.delete;
      context.read<UsuariosBloc>().add(UsuariosDeleteRequested(user.id));
    }
  }

  String _messageFor(S l, _MutationKind kind) => switch (kind) {
        _MutationKind.create => l.userCreated,
        _MutationKind.update => l.userUpdated,
        _MutationKind.delete => l.userDeleted,
      };

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: BlocListener<UsuariosBloc, UsuariosState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (ctx, state) {
          if (state.status == UsuariosStatus.success && _pending != null) {
            final kind = _pending!;
            _pending = null;
            // Solo el form sheet necesita cierre automático. Para delete no
            // hay modal abierto, así que se salta el pop.
            if (kind != _MutationKind.delete) {
              final nav = Navigator.of(ctx);
              if (nav.canPop()) nav.pop();
            }
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(_messageFor(l, kind))),
            );
          } else if (state.status == UsuariosStatus.error &&
              state.failure != null) {
            _pending = null;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                SectionHeader(
                  title: l.tenantUsersTitle,
                  subtitle: l.tenantUsersSubtitle,
                  showBack: true,
                ),
                Expanded(
                  child: BlocBuilder<UsuariosBloc, UsuariosState>(
                    builder: (context, state) {
                      return switch (state.status) {
                        UsuariosStatus.initial ||
                        UsuariosStatus.loading =>
                          const AppLoading(),
                        UsuariosStatus.error => AppErrorView(
                            failure: state.failure!,
                            onRetry: () => context
                                .read<UsuariosBloc>()
                                .add(const UsuariosStarted()),
                          ),
                        UsuariosStatus.loaded ||
                        UsuariosStatus.submitting ||
                        UsuariosStatus.success =>
                          ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: state.items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final u = state.items[i];
                              return _UserTile(
                                user: u,
                                onEdit: () => _openFormSheet(user: u),
                                onDelete: () => _confirmDelete(u),
                              );
                            },
                          ),
                      };
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: AppSquircleFab(
                onPressed: () => _openFormSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UsuarioTenant user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _UserTile({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = S.of(context);
    final initials = _initials(user.nombre);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.secondary, cs.primary],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nombre,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              user.rol,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: cs.onSurfaceVariant,
            onPressed: onEdit,
            tooltip: l.editUser,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: cs.error,
            onPressed: onDelete,
            tooltip: l.deleteUser,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}
