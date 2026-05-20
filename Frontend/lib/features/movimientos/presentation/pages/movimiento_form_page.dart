import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/movimiento_form_bloc.dart';
import '../bloc/movimientos_list_bloc.dart';

class MovimientoFormPage extends StatelessWidget {
  const MovimientoFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MovimientoFormBloc>(
      create: (_) => getIt<MovimientoFormBloc>(),
      child: const _MovimientoFormView(),
    );
  }
}

class _MovimientoFormView extends StatefulWidget {
  const _MovimientoFormView();
  @override
  State<_MovimientoFormView> createState() => _MovimientoFormViewState();
}

class _MovimientoFormViewState extends State<_MovimientoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _animalIdCtrl = TextEditingController();
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _animalIdCtrl.dispose();
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<MovimientoFormBloc>().add(
          MovimientoFormSubmitted(
            animalId: int.parse(_animalIdCtrl.text),
            potreroOrigenId: _origenCtrl.text.trim(),
            potreroDestinoId: _destinoCtrl.text.trim(),
            fecha: _fecha,
            motivo: _motivoCtrl.text.trim().isEmpty
                ? null
                : _motivoCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<MovimientoFormBloc, MovimientoFormState>(
        listener: (context, state) {
          if (state.status == MovimientoFormStatus.success) {
            getIt<MovimientosListBloc>().add(const MovimientosListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.movementRegistered),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/money/movimientos');
          }
          if (state.status == MovimientoFormStatus.failure &&
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
          final loading = state.status == MovimientoFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: t.newMovement,
                subtitle: t.transferAnimal,
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
                          controller: _animalIdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.animalId,
                            hintText: '1',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return t.required;
                            if (int.tryParse(v) == null) {
                              return 'Debe ser número';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _origenCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: t.originPaddock,
                            hintText: 'POT001',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _destinoCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: t.destinationPaddock,
                            hintText: 'POT002',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          leading: Icon(Icons.calendar_today, color: cs.primary),
                          title: Text(t.transferDate),
                          subtitle: Text(_fecha.toIso8601String().substring(0, 10)),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fecha,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                            );
                            if (picked != null) setState(() => _fecha = picked);
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _motivoCtrl,
                          decoration: InputDecoration(
                            labelText: t.reason,
                            hintText: 'Rotación de pastoreo',
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
                              : Text(t.registerTransfer),
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
