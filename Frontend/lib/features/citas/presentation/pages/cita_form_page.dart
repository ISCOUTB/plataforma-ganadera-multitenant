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
    final result = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => _DateTimePickerDialog(initialDate: _fechaHora),
    );
    if (result != null) setState(() => _fechaHora = result);
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

class _DateTimePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  const _DateTimePickerDialog({required this.initialDate});

  @override
  State<_DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<_DateTimePickerDialog> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late PageController _pageController;

  static List<TimeOfDay> get _slots {
    final slots = <TimeOfDay>[];
    for (int h = 7; h < 17; h++) {
      slots.add(TimeOfDay(hour: h, minute: 0));
      slots.add(TimeOfDay(hour: h, minute: 30));
    }
    slots.add(const TimeOfDay(hour: 17, minute: 0));
    return slots;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    final now = DateTime.now();
    final monthDiff = (_selectedDate.year - now.year) * 12 + (_selectedDate.month - now.month);
    _pageController = PageController(initialPage: monthDiff.clamp(0, 11));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const names = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    return names[month - 1];
  }

  String _formatSlot(TimeOfDay t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'pm' : 'am';
    return '$h:$m$ampm';
  }

  Widget _buildCalendar(DateTime month, ColorScheme cs, TextTheme tt) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    int startWeekday = firstDay.weekday - 1;
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            ),
            Text('${_monthName(month.month)} ${month.year}', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Lu','Ma','Mi','Ju','Vi','Sa','Do']
              .map((d) => SizedBox(width: 32, child: Center(child: Text(d, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)))))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (_, i) {
            if (i < startWeekday) return const SizedBox();
            final day = i - startWeekday + 1;
            final date = DateTime(month.year, month.month, day);
            final isSelected = _selectedDate.year == date.year && _selectedDate.month == date.month && _selectedDate.day == date.day;
            final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
            return GestureDetector(
              onTap: isPast ? null : () => setState(() { _selectedDate = date; _selectedTime = null; }),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: tt.bodySmall?.copyWith(
                      color: isPast ? cs.onSurfaceVariant.withValues(alpha: 0.3) : isSelected ? cs.onPrimary : cs.onSurface,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final slots = _slots;
    final now = DateTime.now();
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 560,
        height: isMobile ? MediaQuery.of(context).size.height * 0.85 : 460,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seleccionar fecha y hora', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (isMobile) ...[
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 12,
                  itemBuilder: (_, page) {
                    final month = DateTime(now.year, now.month + page);
                    return _buildCalendar(month, cs, tt);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (_, i) {
                    final slot = slots[i];
                    final isSelected = _selectedTime == slot;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTime = slot),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? cs.primary : Colors.transparent,
                          border: Border.all(color: isSelected ? cs.primary : cs.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _formatSlot(slot),
                            style: tt.labelSmall?.copyWith(
                              color: isSelected ? cs.onPrimary : cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 12,
                        itemBuilder: (_, page) {
                          final month = DateTime(now.year, now.month + page);
                          return _buildCalendar(month, cs, tt);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 1, color: cs.outlineVariant),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              itemCount: slots.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (_, i) {
                                final slot = slots[i];
                                final isSelected = _selectedTime == slot;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedTime = slot),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? cs.primary : Colors.transparent,
                                      border: Border.all(color: isSelected ? cs.primary : cs.outlineVariant),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _formatSlot(slot),
                                        style: tt.bodySmall?.copyWith(
                                          color: isSelected ? cs.onPrimary : cs.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedTime == null ? null : () {
                    final result = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                    Navigator.of(context).pop(result);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}