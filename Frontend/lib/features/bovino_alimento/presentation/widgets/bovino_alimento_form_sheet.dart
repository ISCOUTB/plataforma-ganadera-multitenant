import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../alimentos/domain/entities/alimento.dart';
import '../../../alimentos/domain/repositories/alimento_repository.dart';
import '../bloc/bovino_alimento_bloc.dart';

class BovinoAlimentoFormSheet extends StatefulWidget {
  final int animalId;
  const BovinoAlimentoFormSheet({super.key, required this.animalId});

  @override
  State<BovinoAlimentoFormSheet> createState() =>
      _BovinoAlimentoFormSheetState();
}

class _BovinoAlimentoFormSheetState extends State<BovinoAlimentoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController();

  List<Alimento> _alimentos = const [];
  bool _loadingAlimentos = true;
  AppFailure? _alimentosError;

  Alimento? _selectedAlimento;
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAlimentos();
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAlimentos() async {
    setState(() {
      _loadingAlimentos = true;
      _alimentosError = null;
    });
    final result = await getIt<AlimentoRepository>().list(limit: 100);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loadingAlimentos = false;
        _alimentosError = f;
      }),
      (page) => setState(() {
        _loadingAlimentos = false;
        _alimentos = page.data;
      }),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAlimento == null) return;
    final cantidad = double.parse(_cantidadCtrl.text.replaceAll(',', '.'));
    context.read<BovinoAlimentoBloc>().add(
          BovinoAlimentoAssign(
            animalId: widget.animalId,
            alimentoId: _selectedAlimento!.id,
            cantidad: cantidad,
            fecha: _fecha,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    final dateFmt = DateFormat('dd MMM yyyy', 'es_CO');
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<BovinoAlimentoBloc, BovinoAlimentoState>(
      listener: (ctx, state) {
        if (state.status == BovinoAlimentoStatus.success) {
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(l.feedingRegistered)),
          );
        } else if (state.status == BovinoAlimentoStatus.error &&
            state.failure != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      child: Padding(
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
                        PhosphorIcons.plant(PhosphorIconsStyle.fill),
                        color: cs.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.addFeeding,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildAlimentoField(cs, l),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: l.amountKg,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l.required;
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) return l.required;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(6),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l.feedingDate,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(dateFmt.format(_fecha)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<BovinoAlimentoBloc, BovinoAlimentoState>(
                    buildWhen: (a, b) => a.status != b.status,
                    builder: (context, state) {
                      final submitting =
                          state.status == BovinoAlimentoStatus.submitting;
                      final disabled = _loadingAlimentos ||
                          _alimentos.isEmpty ||
                          submitting;
                      return FilledButton(
                        onPressed: disabled ? null : _submit,
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
                            : Text(l.save),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlimentoField(ColorScheme cs, S l) {
    if (_loadingAlimentos) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_alimentosError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _alimentosError!.message,
              style: TextStyle(color: cs.error),
            ),
          ),
          TextButton(onPressed: _loadAlimentos, child: Text(l.retry)),
        ],
      );
    }
    if (_alimentos.isEmpty) {
      return Text(
        l.noFood,
        style: TextStyle(color: cs.onSurfaceVariant),
      );
    }
    return DropdownButtonFormField<Alimento>(
      initialValue: _selectedAlimento,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l.selectFood,
        border: const OutlineInputBorder(),
      ),
      items: _alimentos
          .map(
            (a) => DropdownMenuItem<Alimento>(
              value: a,
              child: Text(a.tipoAlimento, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedAlimento = v),
      validator: (v) => v == null ? l.required : null,
    );
  }
}
