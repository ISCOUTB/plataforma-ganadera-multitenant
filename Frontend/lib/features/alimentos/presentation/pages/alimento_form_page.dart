import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../bloc/alimento_form_bloc.dart';
import '../bloc/alimentos_list_bloc.dart';

class AlimentoFormPage extends StatelessWidget {
  final String? editId;
  const AlimentoFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlimentoFormBloc>(
      create: (_) => getIt<AlimentoFormBloc>(),
      child: _AlimentoFormView(editId: editId),
    );
  }
}

class _AlimentoFormView extends StatefulWidget {
  final String? editId;
  const _AlimentoFormView({this.editId});
  @override
  State<_AlimentoFormView> createState() => _AlimentoFormViewState();
}

class _AlimentoFormViewState extends State<_AlimentoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _frecuenciaCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();

  bool get isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _idCtrl.text = widget.editId!;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _tipoCtrl.dispose();
    _cantidadCtrl.dispose();
    _frecuenciaCtrl.dispose();
    _costoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AlimentoFormBloc>().add(
          AlimentoFormSubmitted(
            editId: widget.editId,
            id: _idCtrl.text.trim(),
            tipoAlimento: _tipoCtrl.text.trim(),
            cantidadTotal: double.tryParse(_cantidadCtrl.text),
            frecuencia: _frecuenciaCtrl.text.trim().isEmpty
                ? null
                : _frecuenciaCtrl.text.trim(),
            costo: double.tryParse(_costoCtrl.text),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<AlimentoFormBloc, AlimentoFormState>(
        listener: (context, state) {
          if (state.status == AlimentoFormStatus.success) {
            getIt<AlimentosListBloc>().add(const AlimentosListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? t.foodUpdated : t.foodCreated),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/money/alimentos');
          }
          if (state.status == AlimentoFormStatus.failure &&
              state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state.status == AlimentoFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: isEdit ? t.editFood : t.newFood,
                subtitle: isEdit ? widget.editId : null,
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
                            labelText: t.foodId,
                            hintText: 'ALI001',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _tipoCtrl,
                          decoration: InputDecoration(
                            labelText: t.foodType,
                            hintText: 'Pasto kikuyo, concentrado...',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _cantidadCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: t.totalQuantity,
                            hintText: '500 (kg o unidades)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _frecuenciaCtrl,
                          decoration: InputDecoration(
                            labelText: t.frequency,
                            hintText: 'diario, semanal...',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _costoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: t.cost,
                            prefixText: '\$ ',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : Text(isEdit ? t.saveChanges : t.createFood),
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
