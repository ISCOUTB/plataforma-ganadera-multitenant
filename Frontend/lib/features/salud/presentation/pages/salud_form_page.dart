import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/salud.dart';
import '../bloc/salud_form_bloc.dart';
import '../bloc/salud_list_bloc.dart';

class SaludFormPage extends StatelessWidget {
  final int? editId;
  const SaludFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SaludFormBloc>(
      create: (_) => getIt<SaludFormBloc>(),
      child: _SaludFormView(editId: editId),
    );
  }
}

class _SaludFormView extends StatefulWidget {
  final int? editId;
  const _SaludFormView({this.editId});
  @override
  State<_SaludFormView> createState() => _SaludFormViewState();
}

class _SaludFormViewState extends State<_SaludFormView> {
  final _formKey = GlobalKey<FormState>();
  final _productoCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  final _animalIdCtrl = TextEditingController();

  TipoIntervencion _tipo = TipoIntervencion.vacunacion;
  DateTime _fechaAplicacion = DateTime.now();
  DateTime? _fechaProxima;

  bool get isEdit => widget.editId != null;

  @override
  void dispose() {
    _productoCtrl.dispose();
    _dosisCtrl.dispose();
    _costoCtrl.dispose();
    _animalIdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SaludFormBloc>().add(
          SaludFormSubmitted(
            editId: widget.editId,
            tipoIntervencion: _tipo,
            productoAplicado: _productoCtrl.text.trim().isEmpty
                ? null
                : _productoCtrl.text.trim(),
            dosis: _dosisCtrl.text.trim().isEmpty ? null : _dosisCtrl.text.trim(),
            fechaAplicacion: _fechaAplicacion,
            fechaProximaAplicacion: _fechaProxima,
            costo: double.tryParse(_costoCtrl.text),
            animalId: int.tryParse(_animalIdCtrl.text),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<SaludFormBloc, SaludFormState>(
        listener: (context, state) {
          if (state.status == SaludFormStatus.success) {
            getIt<SaludListBloc>().add(const SaludListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? t.recordUpdated : t.recordCreated),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/health/salud');
          }
          if (state.status == SaludFormStatus.failure && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state.status == SaludFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: isEdit ? t.editHealthRecord : t.newHealthRecord,
                subtitle: isEdit ? '#${widget.editId}' : t.newHealthHint,
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
                        DropdownButtonFormField<TipoIntervencion>(
                          initialValue: _tipo,
                          decoration:
                              InputDecoration(labelText: t.interventionType),
                          items: TipoIntervencion.values
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.label),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(
                              () => _tipo = v ?? TipoIntervencion.vacunacion),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _productoCtrl,
                          decoration: InputDecoration(
                            labelText: t.appliedProduct,
                            hintText: 'Vacuna Aftosa, Ivermectina...',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _dosisCtrl,
                          decoration: InputDecoration(
                            labelText: t.dose,
                            hintText: '5ml',
                          ),
                        ),
                        const SizedBox(height: 14),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          leading: Icon(Icons.calendar_today, color: cs.primary),
                          title: Text(t.applicationDate),
                          subtitle: Text(_fechaAplicacion
                              .toIso8601String()
                              .substring(0, 10)),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fechaAplicacion,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                            );
                            if (picked != null) {
                              setState(() => _fechaAplicacion = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          leading: Icon(Icons.event_repeat, color: cs.primary),
                          title: Text(t.nextApplication),
                          subtitle: Text(_fechaProxima
                                  ?.toIso8601String()
                                  .substring(0, 10) ??
                              t.notDefined),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fechaProxima ??
                                  DateTime.now()
                                      .add(const Duration(days: 180)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 3)),
                            );
                            if (picked != null) {
                              setState(() => _fechaProxima = picked);
                            }
                          },
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
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _animalIdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.animalId,
                            hintText: '1',
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
                              : Text(isEdit ? t.saveChanges : t.createRecord),
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
