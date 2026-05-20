import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/animal.dart';
import '../bloc/animal_form_bloc.dart';
import '../bloc/animales_list_bloc.dart';

class AnimalFormPage extends StatelessWidget {
  final int? editId;
  const AnimalFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalFormBloc>(
      create: (_) => getIt<AnimalFormBloc>(),
      child: _AnimalFormView(editId: editId),
    );
  }
}

class _AnimalFormView extends StatefulWidget {
  final int? editId;
  const _AnimalFormView({this.editId});

  @override
  State<_AnimalFormView> createState() => _AnimalFormViewState();
}

class _AnimalFormViewState extends State<_AnimalFormView> {
  final _formKey = GlobalKey<FormState>();
  final _numIdCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _razaCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  final _fincaIdCtrl = TextEditingController();
  final _potreroIdCtrl = TextEditingController();

  AnimalGenero _genero = AnimalGenero.hembra;
  DateTime _fechaNac = DateTime.now().subtract(const Duration(days: 365));

  bool get isEdit => widget.editId != null;

  @override
  void dispose() {
    _numIdCtrl.dispose();
    _pesoCtrl.dispose();
    _razaCtrl.dispose();
    _alturaCtrl.dispose();
    _fincaIdCtrl.dispose();
    _potreroIdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AnimalFormBloc>().add(
          AnimalFormSubmitted(
            editId: widget.editId,
            numeroIdentificacion: _numIdCtrl.text.trim(),
            fechaNacimiento: _fechaNac,
            genero: _genero,
            peso: double.parse(_pesoCtrl.text),
            raza: _razaCtrl.text.trim(),
            altura: double.tryParse(_alturaCtrl.text),
            fincaId: _fincaIdCtrl.text.trim().isEmpty
                ? null
                : _fincaIdCtrl.text.trim(),
            potreroId: _potreroIdCtrl.text.trim().isEmpty
                ? null
                : _potreroIdCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<AnimalFormBloc, AnimalFormState>(
        listener: (context, state) {
          final t = S.of(context);
          if (state.status == AnimalFormStatus.success) {
            // Refrescar el listado singleton para que muestre el nuevo registro.
            getIt<AnimalesListBloc>().add(const AnimalesListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? t.animalUpdated : t.animalCreated),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/inventory/animales');
          }
          if (state.status == AnimalFormStatus.failure && state.failure != null) {
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
          final loading = state.status == AnimalFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: isEdit ? t.editAnimal : t.newAnimal,
                subtitle:
                    isEdit ? '#${widget.editId}' : t.registerBovine,
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
                          controller: _numIdCtrl,
                          decoration: InputDecoration(
                            labelText: t.idNumber,
                            hintText: 'BOV-2024-001',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _razaCtrl,
                          decoration: InputDecoration(
                            labelText: t.breed,
                            hintText: 'Brahman',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<AnimalGenero>(
                          initialValue: _genero,
                          decoration: InputDecoration(
                              labelText: t.gender),
                          items: AnimalGenero.values
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g.label),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _genero = v ?? AnimalGenero.hembra),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pesoCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: t.weight,
                            hintText: '450',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return t.required;
                            if (double.tryParse(v) == null) return 'Número inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _alturaCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: t.height,
                            hintText: '1.35',
                          ),
                        ),
                        const SizedBox(height: 14),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          leading: Icon(Icons.calendar_today,
                              color: cs.primary),
                          title: Text(t.birthDate),
                          subtitle: Text(
                              _fechaNac.toIso8601String().substring(0, 10)),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fechaNac,
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _fechaNac = picked);
                            }
                          },
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
                        TextFormField(
                          controller: _potreroIdCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: t.paddockId,
                            hintText: 'POT001',
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
                              : Text(
                                  isEdit ? t.saveChanges : t.createAnimal),
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
