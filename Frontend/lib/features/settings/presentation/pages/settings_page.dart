import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;

    final t = S.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(t.settingsTitle,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(t.settingsSubtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 24),
          if (user != null) _ProfileCard(user: user),
          const SizedBox(height: 20),
          _SectionTitle(t.organization),
          _SettingsTile(
            icon: PhosphorIcons.users(PhosphorIconsStyle.bold),
            label: t.tenantUsers,
            onTap: () => context.push('/settings/usuarios'),
          ),
          if (user != null && user.rol == 'superadmin')
            _SettingsTile(
              icon: PhosphorIcons.crown(PhosphorIconsStyle.bold),
              label: 'Panel de administración',
              onTap: () => context.push('/settings/admin'),
            ),
          const SizedBox(height: 16),
          _SectionTitle(t.account),
          _SettingsTile(
            icon: PhosphorIcons.key(PhosphorIconsStyle.bold),
            label: t.changePassword,
            onTap: () => _showChangePasswordDialog(context),
          ),
          _SettingsTile(
            icon: PhosphorIcons.bell(PhosphorIconsStyle.bold),
            label: t.notifications,
            onTap: () => context.push('/settings/notificaciones'),
          ),
          _SettingsTile(
            icon: PhosphorIcons.translate(PhosphorIconsStyle.bold),
            label: t.language,
            trailing: getIt<LocaleController>().currentLabel,
            onTap: () {
              getIt<LocaleController>().toggleLocale();
            },
          ),
          _DarkModeTile(),
          const SizedBox(height: 20),
          _SectionTitle(t.about),
          _SettingsTile(
            icon: PhosphorIcons.info(PhosphorIconsStyle.bold),
            label: t.version,
            trailing: '1.0.0',
            onTap: null,
          ),
          _SettingsTile(
            icon: PhosphorIcons.fileText(PhosphorIconsStyle.bold),
            label: t.termsAndPrivacy,
            onTap: () => _comingSoon(context, t.termsAndPrivacy),
          ),
          const SizedBox(height: 28),
          _LogoutButton(),
          const SizedBox(height: 24),
          Center(
            child: Text(
              t.copyright,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label — disponible en Fase E'),
          backgroundColor: cs.primary,
        ),
      );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ChangePasswordDialog(
        formKey: formKey,
        currentPassCtrl: currentPassCtrl,
        newPassCtrl: newPassCtrl,
        confirmPassCtrl: confirmPassCtrl,
        cs: cs,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Contraseña actualizada'),
              backgroundColor: cs.primary,
            ),
          );
        },
        onError: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Contraseña actual incorrecta'),
              backgroundColor: cs.error,
            ),
          );
        },
        user: context.read<AuthBloc>().state.user,
      ),
    );

    currentPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPassCtrl;
  final TextEditingController newPassCtrl;
  final TextEditingController confirmPassCtrl;
  final ColorScheme cs;
  final VoidCallback onSuccess;
  final VoidCallback onError;
  final dynamic user;

  const _ChangePasswordDialog({
    required this.formKey,
    required this.currentPassCtrl,
    required this.newPassCtrl,
    required this.confirmPassCtrl,
    required this.cs,
    required this.onSuccess,
    required this.onError,
    required this.user,
  });

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar contraseña'),
      content: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: widget.currentPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.confirmPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              validator: (v) => v != widget.newPassCtrl.text
                  ? 'Las contraseñas no coinciden'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Guardar', style: TextStyle(color: widget.cs.primary)),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!widget.formKey.currentState!.validate()) return;
    if (widget.user == null) return;

    setState(() => _loading = true);

    final dio = getIt<DioClient>().dio;
    try {
      await dio.post('/auth/login', data: {
        'email': widget.user.email,
        'password': widget.currentPassCtrl.text,
      });
      await dio.patch('/usuarios/${widget.user.id}', data: {
        'password': widget.newPassCtrl.text,
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        widget.onError();
      }
    }
  }
}

class _ProfileCard extends StatelessWidget {
  final User user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = _initialsOf(user.nombre);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
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
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(label: user.rol),
                    const SizedBox(width: 6),
                    _Chip(label: user.tenantId, outlined: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool outlined;
  const _Chip({required this.label, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: outlined
            ? Colors.transparent
            : cs.primary.withValues(alpha: 0.12),
        border: outlined ? Border.all(color: cs.outline, width: 1) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: outlined ? cs.onSurfaceVariant : cs.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: PhosphorIcon(icon, color: cs.primary, size: 20),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        trailing: trailing != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailing!,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: cs.onSurfaceVariant,
                      size: 18,
                    ),
                  ],
                ],
              )
            : (onTap != null
                ? Icon(Icons.chevron_right,
                    color: cs.onSurfaceVariant, size: 18)
                : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return SizedBox(
          width: double.infinity,
          child: Material(
            color: cs.error,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: loading ? null : () => _confirmLogout(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (loading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.logout, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context).logout,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final t = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.logoutConfirm),
        content: Text(t.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }
}

class _DarkModeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = getIt<ThemeController>();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ctrl,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            secondary: PhosphorIcon(
              isDark
                  ? PhosphorIcons.moon(PhosphorIconsStyle.bold)
                  : PhosphorIcons.sun(PhosphorIconsStyle.bold),
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            title: Text(
              isDark ? 'Modo oscuro' : 'Modo claro',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            value: isDark,
            onChanged: (_) => ctrl.toggleTheme(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}