import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../veterinarios/domain/repositories/veterinarios_repository.dart';
import '../../../veterinarios/domain/entities/veterinario.dart';
import '../../domain/entities/cita.dart';
import '../../domain/repositories/citas_repository.dart';
import '../bloc/citas_bloc.dart';

class CitaFormPage extends StatefulWidget {
  final int? editId;
  const CitaFormPage({super.key, this.editId});

  @override
  State<CitaFormPage> createState() => _CitaFormPageState();
}

class _CitaFormPageState extends State<CitaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notasCtrl = TextEditingController();
  final _recordatorioCtrl = TextEditingController();

  TipoCita _tipo = TipoCita.revisionGeneral;
  AlcanceCita _alcance = AlcanceCita.animal;
  DateTime _fechaHora = DateTime.now().add(const Duration(days: 1));
  Veterinario? _veterinarioSeleccionado;
  List<Veterinario> _veterinarios = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadVeterinarios();
  }

  Future<void> _loadVeterinarios() async {
    final vets = await getIt<VeterinariosRepository>().getAll();
    setState(() => _veterinarios = vets);
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    _recordatorioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFechaHora() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_fechaHora));
    if (time == null) return;
    setState(() => _fechaHora = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_veterinarioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un veterinario')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final data = {
        'tipo': _tipo.apiValue,
        'alcance': _alcance.apiValue,
        'fecha_hora': _fechaHora.toIso8601String(),
        'fk_id_veterinario': _veterinarioSeleccionado!.id,
        if (_notasCtrl.text.isNotEmpty) 'notas': _notasCtrl.text.trim(),
        if (_recordatorioCtrl.text.isNotEmpty) 'recordatorio_dias': int.tryParse(_recordatorioCtrl.text),
      };
      await getIt<CitasRepository>().create(data);
      if (mounted) {
        getIt<CitasBloc>().add(const CitasRefreshed());
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SectionHeader(title: 'Nueva cita', subtitle: 'Programar visita veterinaria', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<TipoCita>(
                      value: _tipo,
                      decoration: const InputDecoration(labelText: 'Tipo de cita'),
                      items: TipoCita.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                      onChanged: (v) => setState(() => _tipo = v ?? TipoCita.revisionGeneral),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<AlcanceCita>(
                      value: _alcance,
                      decoration: const InputDecoration(labelText: 'Alcance'),
                      items: AlcanceCita.values.map((a) => DropdownMenuItem(value: a, child: Text(a.label))).toList(),
                      onChanged: (v) => setState(() => _alcance = v ?? AlcanceCita.animal),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<Veterinario>(
                      value: _veterinarioSeleccionado,
                      decoration: const InputDecoration(labelText: 'Veterinario'),
                      items: _veterinarios.map((v) => DropdownMenuItem(value: v, child: Text(v.nombre))).toList(),
                      onChanged: (v) => setState(() => _veterinarioSeleccionado = v),
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: cs.outline)),
                      leading: Icon(Icons.calendar_today, color: cs.primary),
                      title: const Text('Fecha y hora'),
                      subtitle: Text('${_fechaHora.day}/${_fechaHora.month}/${_fechaHora.year} ${_fechaHora.hour}:${_fechaHora.minute.toString().padLeft(2, '0')}'),
                      onTap: _pickFechaHora,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _recordatorioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Recordatorio (días antes)', hintText: '3'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notasCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notas'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Crear cita'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
