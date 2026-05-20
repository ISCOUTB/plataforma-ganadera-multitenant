import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/usuario_tenant.dart';
import '../bloc/usuarios_bloc.dart';

const List<String> _roles = ['admin', 'propietario', 'empleado'];

class UsuarioFormSheet extends StatelessWidget {
  final UsuariosBloc bloc;
  final UsuarioTenant? user;

  const UsuarioFormSheet({
    super.key,
    required this.bloc,
    this.user,
  });

  bool get _isEdit => user != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsuariosBloc>.value(
      value: bloc,
      child: _UsuarioFormBody(user: user, isEdit: _isEdit),
    );
  }
}

class _UsuarioFormBody extends StatefulWidget {
  final UsuarioTenant? user;
  final bool isEdit;
  const _UsuarioFormBody({required this.user, required this.isEdit});

  @override
  State<_UsuarioFormBody> createState() => _UsuarioFormBodyState();
}

class _UsuarioFormBodyState extends State<_UsuarioFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late String _rol;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passwordCtrl = TextEditingController();
    _rol = _roles.contains(u?.rol) ? u!.rol : 'empleado';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bloc = context.read<UsuariosBloc>();
    if (widget.isEdit) {
      bloc.add(UsuariosUpdateRequested(
        id: widget.user!.id,
        nombre: _nombreCtrl.text.trim(),
        rol: _rol,
      ));
    } else {
      bloc.add(UsuariosCreateRequested(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        nombre: _nombreCtrl.text.trim(),
        rol: _rol,
      ));
    }
  }

  String _roleLabel(S l, String rol) => switch (rol) {
        'admin' => l.roleAdmin,
        'propietario' => l.rolePropietario,
        _ => l.roleEmpleado,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.user(PhosphorIconsStyle.fill),
                      color: cs.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.isEdit ? l.editUser : l.addUser,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: InputDecoration(
                    labelText: l.fullName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l.required : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  readOnly: widget.isEdit,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l.email,
                    hintText: l.emailHint,
                    border: const OutlineInputBorder(),
                    filled: widget.isEdit,
                    fillColor: widget.isEdit
                        ? cs.onSurface.withValues(alpha: 0.04)
                        : null,
                  ),
                  validator: (v) {
                    if (widget.isEdit) return null;
                    if (v == null || v.trim().isEmpty) return l.required;
                    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!re.hasMatch(v.trim())) return l.emailInvalid;
                    return null;
                  },
                ),
                if (!widget.isEdit) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l.password,
                      hintText: l.passwordHint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) return l.passwordMin;
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _rol,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.role,
                    border: const OutlineInputBorder(),
                  ),
                  items: _roles
                      .map(
                        (r) => DropdownMenuItem<String>(
                          value: r,
                          child: Text(_roleLabel(l, r)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _rol = v);
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<UsuariosBloc, UsuariosState>(
                  buildWhen: (a, b) => a.status != b.status,
                  builder: (context, state) {
                    final submitting =
                        state.status == UsuariosStatus.submitting;
                    return FilledButton(
                      onPressed: submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isEdit ? l.saveChanges : l.save),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
