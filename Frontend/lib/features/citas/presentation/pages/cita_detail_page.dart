import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/cita.dart';
import '../../domain/repositories/citas_repository.dart';

class CitaDetailPage extends StatefulWidget {
  final int citaId;
  const CitaDetailPage({super.key, required this.citaId});

  @override
  State<CitaDetailPage> createState() => _CitaDetailPageState();
}

class _CitaDetailPageState extends State<CitaDetailPage> {
  Cita? _cita;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await getIt<CitasRepository>().getOne(widget.citaId);
    if (!mounted) return;
    setState(() { _cita = c; _loading = false; });
  }

  Future<void> _cancelar() async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: const Text('¿Seguro que quieres cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              confirmed = true;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirmed) {
      await getIt<CitasRepository>().update(_cita!.id, {'estado': 'cancelada'});
      if (!mounted) return;
      await _load();
    }
  }

  Future<void> _posponer() async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => _DateTimePickerDialog(initialDate: _cita!.fechaHora),
    );
    if (result == null) return;
    if (!mounted) return;

    await getIt<CitasRepository>().update(_cita!.id, {
      'fecha_hora': result.toIso8601String(),
      'estado': 'pendiente',
    });
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Scaffold(body: AppLoading());

    final c = _cita!;
    final color = switch (c.estado) {
      EstadoCita.pendiente => cs.tertiary,
      EstadoCita.completada => cs.primary,
      EstadoCita.cancelada => cs.error,
    };

    final esPendiente = c.estado == EstadoCita.pendiente;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SectionHeader(title: c.tipo.label, subtitle: 'Detalle de cita', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(left: BorderSide(color: color, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                              child: Text(c.estado.label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999)),
                              child: Text(c.alcance.label, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(label: 'Tipo', value: c.tipo.label),
                        _InfoRow(label: 'Veterinario', value: c.veterinario?.nombre ?? '—'),
                        _InfoRow(
                          label: 'Fecha y hora',
                          value: '${c.fechaHora.day}/${c.fechaHora.month}/${c.fechaHora.year} ${c.fechaHora.hour}:${c.fechaHora.minute.toString().padLeft(2, '0')}',
                        ),
                        if (c.recordatorioDias != null)
                          _InfoRow(label: 'Recordatorio', value: '${c.recordatorioDias} días antes'),
                        if (c.notas != null && c.notas!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Notas', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                            child: Text(c.notas!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (esPendiente) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _posponer,
                      icon: const Icon(Icons.calendar_month_outlined, size: 18),
                      label: const Text('Posponer cita'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _cancelar,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancelar cita'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 560,
        height: 460,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seleccionar fecha y hora', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          Expanded(child: Text(value, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}