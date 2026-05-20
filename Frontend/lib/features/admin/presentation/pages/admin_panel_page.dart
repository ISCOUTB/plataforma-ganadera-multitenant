import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/tenant_summary.dart';
import '../bloc/admin_bloc.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminBloc>(
      create: (_) => getIt<AdminBloc>()..add(const AdminDataLoaded()),
      child: const _AdminPanelView(),
    );
  }
}

class _AdminPanelView extends StatelessWidget {
  const _AdminPanelView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state.status == AdminStatus.created &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: cs.primary,
              ),
            );
          }
          if (state.status == AdminStatus.error && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AdminStatus.initial ||
              state.status == AdminStatus.loading) {
            return const AppLoading();
          }
          if (state.status == AdminStatus.error && state.tenants.isEmpty) {
            return AppErrorView(
              failure: state.failure!,
              onRetry: () =>
                  context.read<AdminBloc>().add(const AdminDataLoaded()),
            );
          }
          return RefreshIndicator(
            color: cs.primary,
            onRefresh: () async {
              context.read<AdminBloc>().add(const AdminDataLoaded());
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                SectionHeader(
                  title: 'Panel de administración',
                  subtitle: 'Gestión global de tenants y usuarios',
                  showBack: true,
                  trailing: Material(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showCreateUserSheet(context),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child:
                            Icon(Icons.person_add, color: cs.onPrimary, size: 22),
                      ),
                    ),
                  ),
                ),
                // Tenants section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'TENANTS (${state.tenants.length})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final t in state.tenants)
                  _TenantCard(tenant: t),
                const SizedBox(height: 24),
                // Users section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'USUARIOS (${state.users.length})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final u in state.users) _UserCard(user: u),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateUserSheet(BuildContext context) {
    final bloc = context.read<AdminBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: _CreateUserForm(
          onSubmit: (email, password, nombre, tenantId, rol) {
            bloc.add(AdminUserCreated(
              email: email,
              password: password,
              nombre: nombre,
              tenantId: tenantId,
              rol: rol,
            ));
            Navigator.of(sheetCtx).pop();
          },
        ),
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final TenantSummary tenant;
  const _TenantCard({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = tenant.tenantId;
    final count = tenant.userCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PhosphorIcon(
                PhosphorIcons.buildings(PhosphorIconsStyle.fill),
                color: cs.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '$count usuario(s)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final nombre = user.nombre;
    final email = user.email;
    final rol = user.rol;
    final tenant = user.tenantId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.secondary, cs.primary],
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(nombre),
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    rol,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tenant,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}

class _CreateUserForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String nombre,
    String tenantId,
    String rol,
  ) onSubmit;

  const _CreateUserForm({required this.onSubmit});

  @override
  State<_CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<_CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _tenantCtrl = TextEditingController();
  String _rol = 'admin';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nombreCtrl.dispose();
    _tenantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Crear usuario',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Asigna un usuario a un tenant específico',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Email inválido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mín 6 caracteres' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tenantCtrl,
              decoration: const InputDecoration(
                labelText: 'Tenant ID',
                hintText: 'tenant-demo',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _rol,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(
                    value: 'propietario', child: Text('Propietario')),
                DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
              ],
              onChanged: (v) => setState(() => _rol = v ?? 'admin'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                widget.onSubmit(
                  _emailCtrl.text.trim(),
                  _passCtrl.text,
                  _nombreCtrl.text.trim(),
                  _tenantCtrl.text.trim(),
                  _rol,
                );
              },
              child: const Text('Crear usuario'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
