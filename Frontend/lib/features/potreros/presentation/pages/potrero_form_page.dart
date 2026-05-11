import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/potrero_form_bloc.dart';
import '../bloc/potreros_list_bloc.dart';

class PotreroFormPage extends StatelessWidget {
  final String? editId;
  const PotreroFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PotreroFormBloc>(
      create: (_) => getIt<PotreroFormBloc>(),
      child: _PotreroFormView(editId: editId),
    );
  }
}

class _PotreroFormView extends StatefulWidget {
  final String? editId;
  const _PotreroFormView({this.editId});
  @override
  State<_PotreroFormView> createState() => _PotreroFormViewState();
}

class _PotreroFormViewState extends State<_PotreroFormView> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _fincaIdCtrl = TextEditingController();
  String _estado = 'activo';

  bool get isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _idCtrl.text = widget.editId!;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nombreCtrl.dispose();
    _capacidadCtrl.dispose();
    _areaCtrl.dispose();
    _fincaIdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PotreroFormBloc>().add(
          PotreroFormSubmitted(
            id: _idCtrl.text.trim(),
            nombre: _nombreCtrl.text.trim(),
            capacidadAnimales: int.parse(_capacidadCtrl.text.trim()),
            area: double.tryParse(_areaCtrl.text.trim()),
            estado: _estado,
            fincaId: _fincaIdCtrl.text.trim().isEmpty
                ? null
                : _fincaIdCtrl.text.trim(),
            isEdit: isEdit,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<PotreroFormBloc, PotreroFormState>(
        listener: (context, state) {
          if (state.status == PotreroFormStatus.success) {
            final t = S.of(context);
            getIt<PotrerosListBloc>().add(const PotrerosListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? t.paddockUpdated : t.paddockCreated),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/inventory/potreros');
          }
          if (state.status == PotreroFormStatus.failure && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final t = S.of(context);
          final loading = state.status == PotreroFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: isEdit ? t.editPaddock : t.newPaddock,
                subtitle: isEdit ? widget.editId : t.configurePaddock,
                showBack: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _idCtrl,
                          enabled: !isEdit,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: t.paddockId,
                            hintText: 'POT001',
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? t.required
                              : (v.length > 15 ? 'Máximo 15' : null),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nombreCtrl,
                          decoration: InputDecoration(
                            labelText: t.paddockName,
                            hintText: 'Potrero Norte',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _capacidadCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.capacity,
                            hintText: '50',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return t.required;
                            final n = int.tryParse(v);
                            if (n == null || n < 1) return 'Mínimo 1';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _areaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: t.area,
                            hintText: '12.5',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _fincaIdCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: t.farmId,
                            hintText: 'FINCA001',
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _estado,
                          decoration: InputDecoration(labelText: t.status),
                          items: [
                            DropdownMenuItem(
                                value: 'activo', child: Text(t.statusActive)),
                            DropdownMenuItem(
                                value: 'rotacion', child: Text(t.statusRotation)),
                            DropdownMenuItem(
                                value: 'inactivo', child: Text(t.statusInactive)),
                          ],
                          onChanged: (v) =>
                              setState(() => _estado = v ?? 'activo'),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEdit ? t.saveChanges : t.createPaddock),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
