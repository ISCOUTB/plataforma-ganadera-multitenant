import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/finca_form_bloc.dart';
import '../bloc/fincas_list_bloc.dart';

class FincaFormPage extends StatelessWidget {
  /// Si [editId] viene null → modo crear. Si trae valor → modo editar.
  final String? editId;
  const FincaFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FincaFormBloc>(
      create: (_) => getIt<FincaFormBloc>(),
      child: _FincaFormView(editId: editId),
    );
  }
}

class _FincaFormView extends StatefulWidget {
  final String? editId;
  const _FincaFormView({this.editId});

  @override
  State<_FincaFormView> createState() => _FincaFormViewState();
}

class _FincaFormViewState extends State<_FincaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _propietarioCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

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
    _ubicacionCtrl.dispose();
    _propietarioCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<FincaFormBloc>().add(
          FincaFormSubmitted(
            id: _idCtrl.text.trim(),
            nombre: _nombreCtrl.text.trim(),
            ubicacion: _ubicacionCtrl.text.trim().isEmpty
                ? null
                : _ubicacionCtrl.text.trim(),
            propietario: _propietarioCtrl.text.trim().isEmpty
                ? null
                : _propietarioCtrl.text.trim(),
            areaTotal: double.tryParse(_areaCtrl.text.trim()),
            isEdit: isEdit,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<FincaFormBloc, FincaFormState>(
        listener: (context, state) {
          if (state.status == FincaFormStatus.success) {
            final t = S.of(context);
            getIt<FincasListBloc>().add(const FincasListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? t.farmUpdated : t.farmCreated),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/inventory/fincas');
          }
          if (state.status == FincaFormStatus.failure && state.failure != null) {
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
          final loading = state.status == FincaFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: isEdit ? t.editFarm : t.newFarm,
                subtitle: isEdit ? widget.editId : t.createNewFarm,
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
                          decoration: InputDecoration(
                            labelText: t.farmIdLabel,
                            hintText: 'FINCA001',
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) => (v == null || v.isEmpty)
                              ? t.required
                              : (v.length > 15 ? 'Máximo 15 caracteres' : null),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nombreCtrl,
                          decoration: InputDecoration(
                            labelText: t.farmName,
                            hintText: 'Hacienda El Paraíso',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _ubicacionCtrl,
                          decoration: InputDecoration(
                            labelText: t.location,
                            hintText: 'Córdoba, Colombia',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _propietarioCtrl,
                          decoration: InputDecoration(
                            labelText: t.owner,
                            hintText: 'Nombre del propietario',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _areaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: t.totalArea,
                            hintText: '250.5',
                          ),
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
                              : Text(isEdit ? t.saveChanges : t.createFarm),
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
