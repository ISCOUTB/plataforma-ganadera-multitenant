import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/reproduccion_form_bloc.dart';
import '../bloc/reproduccion_list_bloc.dart';

class ReproduccionFormPage extends StatelessWidget {
  final String? editId;
  const ReproduccionFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReproduccionFormBloc>(
      create: (_) => getIt<ReproduccionFormBloc>(),
      child: _ReproduccionFormView(editId: editId),
    );
  }
}

class _ReproduccionFormView extends StatefulWidget {
  final String? editId;
  const _ReproduccionFormView({this.editId});
  @override
  State<_ReproduccionFormView> createState() => _ReproduccionFormViewState();
}

class _ReproduccionFormViewState extends State<_ReproduccionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _metodoCtrl = TextEditingController();
  final _criasCtrl = TextEditingController();
  bool _enCelo = false;
  bool _prenada = false;
  DateTime? _fechaParto;

  bool get isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _idCtrl.text = widget.editId!;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _metodoCtrl.dispose();
    _criasCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ReproduccionFormBloc>().add(
          ReproduccionFormSubmitted(
            editId: widget.editId,
            id: _idCtrl.text.trim(),
            metodoReproduccion: _metodoCtrl.text.trim().isEmpty
                ? null
                : _metodoCtrl.text.trim(),
            enCelo: _enCelo,
            prenada: _prenada,
            numeroCrias: int.tryParse(_criasCtrl.text),
            fechaEstimadoParto: _fechaParto,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<ReproduccionFormBloc, ReproduccionFormState>(
        listener: (context, state) {
          if (state.status == ReproduccionFormStatus.success) {
            getIt<ReproduccionListBloc>()
                .add(const ReproduccionListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(isEdit ? t.eventUpdated : t.eventCreated),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/health/reproduccion');
          }
          if (state.status == ReproduccionFormStatus.failure &&
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
          final loading = state.status == ReproduccionFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: isEdit ? t.editReproEvent : t.newReproEvent,
                subtitle:
                    isEdit ? widget.editId : t.reproductionSubtitle,
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
                            labelText: t.eventId,
                            hintText: 'REP001',
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? t.required
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _metodoCtrl,
                          decoration: InputDecoration(
                            labelText: t.reproMethod,
                            hintText: 'monta_natural, inseminacion...',
                          ),
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          title: Text(t.inHeat),
                          value: _enCelo,
                          onChanged: (v) => setState(() => _enCelo = v),
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          title: Text(t.pregnant),
                          value: _prenada,
                          onChanged: (v) => setState(() => _prenada = v),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _criasCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.expectedOffspring,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          leading: Icon(Icons.calendar_today, color: cs.primary),
                          title: Text(t.estimatedDueDate),
                          subtitle: Text(_fechaParto
                                  ?.toIso8601String()
                                  .substring(0, 10) ??
                              t.notDefined),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fechaParto ??
                                  DateTime.now()
                                      .add(const Duration(days: 180)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _fechaParto = picked);
                            }
                          },
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
                              : Text(isEdit ? t.saveChanges : t.createEvent),
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
