import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/finanza.dart';
import '../bloc/finanza_form_bloc.dart';
import '../bloc/finanzas_list_bloc.dart';
import '../bloc/finanzas_resumen_bloc.dart';

class FinanzaFormPage extends StatelessWidget {
  final String? editId;
  const FinanzaFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanzaFormBloc>(
      create: (_) => getIt<FinanzaFormBloc>(),
      child: _FinanzaFormView(editId: editId),
    );
  }
}

class _FinanzaFormView extends StatefulWidget {
  final String? editId;
  const _FinanzaFormView({this.editId});
  @override
  State<_FinanzaFormView> createState() => _FinanzaFormViewState();
}

class _FinanzaFormViewState extends State<_FinanzaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _metodoCtrl = TextEditingController();
  final _fincaIdCtrl = TextEditingController();

  TipoMovimiento _tipo = TipoMovimiento.ingreso;
  DateTime _fecha = DateTime.now();

  bool get isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _idCtrl.text = widget.editId!;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _conceptoCtrl.dispose();
    _categoriaCtrl.dispose();
    _montoCtrl.dispose();
    _metodoCtrl.dispose();
    _fincaIdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<FinanzaFormBloc>().add(
          FinanzaFormSubmitted(
            editId: widget.editId,
            id: _idCtrl.text.trim(),
            tipo: _tipo,
            concepto: _conceptoCtrl.text.trim(),
            categoria: _categoriaCtrl.text.trim().isEmpty
                ? null
                : _categoriaCtrl.text.trim(),
            monto: double.parse(_montoCtrl.text),
            fecha: _fecha,
            metodoPago: _metodoCtrl.text.trim().isEmpty
                ? null
                : _metodoCtrl.text.trim(),
            fincaId: _fincaIdCtrl.text.trim().isEmpty
                ? null
                : _fincaIdCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<FinanzaFormBloc, FinanzaFormState>(
        listener: (context, state) {
          if (state.status == FinanzaFormStatus.success) {
            getIt<FinanzasListBloc>().add(const FinanzasListRefreshed());
            getIt<FinanzasResumenBloc>().add(const FinanzasResumenStarted());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(isEdit ? t.transactionUpdated : t.transactionCreated),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/money/finanzas');
          }
          if (state.status == FinanzaFormStatus.failure &&
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
          final loading = state.status == FinanzaFormStatus.submitting;
          return Column(
            children: [
              SectionHeader(
                title: isEdit ? t.editTransaction : t.newTransaction,
                subtitle: isEdit ? widget.editId : t.incomeOrExpense,
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
                            labelText: t.transactionId,
                            hintText: 'FIN001',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<TipoMovimiento>(
                          initialValue: _tipo,
                          decoration: InputDecoration(
                              labelText: t.transactionType),
                          items: TipoMovimiento.values
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.label),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _tipo = v ?? TipoMovimiento.ingreso),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _conceptoCtrl,
                          decoration: InputDecoration(
                            labelText: t.concept,
                            hintText: 'Venta de novillos',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? t.required : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _categoriaCtrl,
                          decoration: InputDecoration(
                            labelText: t.category,
                            hintText: 'venta_ganado, alimentacion...',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _montoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: t.amount,
                            prefixText: '\$ ',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return t.required;
                            if (double.tryParse(v) == null) return 'Número inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cs.outline),
                          ),
                          leading: Icon(Icons.calendar_today, color: cs.primary),
                          title: Text(t.date),
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
                          controller: _metodoCtrl,
                          decoration: InputDecoration(
                            labelText: t.paymentMethod,
                            hintText: 'transferencia, efectivo...',
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
                              : Text(isEdit ? t.saveChanges : t.createTransaction),
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
