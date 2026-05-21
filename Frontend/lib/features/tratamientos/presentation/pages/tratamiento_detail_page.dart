import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/tratamiento.dart';
import '../../domain/repositories/tratamientos_repository.dart';

class TratamientoDetailPage extends StatefulWidget {
  final int tratamientoId;
  const TratamientoDetailPage({super.key, required this.tratamientoId});

  @override
  State<TratamientoDetailPage> createState() => _TratamientoDetailPageState();
}

class _TratamientoDetailPageState extends State<TratamientoDetailPage> {
  Tratamiento? _tratamiento;
  bool _loading = true;
  final _obsCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final t = await getIt<TratamientosRepository>().getOne(widget.tratamientoId);
    if (!mounted) return;
    setState(() { _tratamiento = t; _loading = false; });
  }

  Future<void> _addSeguimiento() async {
    if (_obsCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await getIt<TratamientosRepository>().addSeguimiento(
      widget.tratamientoId,
      {'observacion': _obsCtrl.text.trim()},
    );
    _obsCtrl.clear();
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    setState(() => _submitting = false);
  }

Future<void> _editSeguimiento(SeguimientoTratamiento s) async {
    final ctrl = TextEditingController(text: s.observacion);
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar observación'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Observación'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              confirmed = true;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (confirmed && ctrl.text.trim().isNotEmpty) {
      await getIt<TratamientosRepository>().updateSeguimiento(s.id, ctrl.text.trim());
      if (!mounted) return;
      await _load();
    }
  }

Future<void> _deleteSeguimiento(SeguimientoTratamiento s) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar observación'),
        content: const Text('¿Seguro que quieres eliminar esta observación? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              confirmed = true;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed) {
      debugPrint('Eliminando seguimiento id: ${s.id}');
      await getIt<TratamientosRepository>().deleteSeguimiento(s.id);
      debugPrint('Eliminado ok');
      if (!mounted) return;
      await _load();
    }
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Scaffold(body: AppLoading());

    final t = _tratamiento!;
    final color = switch (t.estado) {
      EstadoTratamiento.enCurso => cs.tertiary,
      EstadoTratamiento.completado => cs.primary,
      EstadoTratamiento.abandonado => cs.error,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SectionHeader(title: 'Tratamiento', subtitle: t.diagnostico, showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                              child: Text(t.estado.label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Animal', value: 'Animal #${t.fkIdBovino}'),
                        _InfoRow(label: 'Veterinario', value: t.veterinario?.nombre ?? '—'),
                        _InfoRow(label: 'Inicio', value: '${t.fechaInicio.day}/${t.fechaInicio.month}/${t.fechaInicio.year}'),
                        if (t.fechaFinEstimada != null)
                          _InfoRow(label: 'Fin estimado', value: '${t.fechaFinEstimada!.day}/${t.fechaFinEstimada!.month}/${t.fechaFinEstimada!.year}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('SEGUIMIENTOS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8, color: cs.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  if (t.seguimientos.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Sin seguimientos aún', style: TextStyle(color: cs.onSurfaceVariant)),
                    ))
                  else
                    ...t.seguimientos.map((s) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(left: BorderSide(color: cs.primary, width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.observacion, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.registradoPor ?? 'Sin nombre', style: theme.textTheme.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)),
                              Text('${s.creadoEn.day}/${s.creadoEn.month}/${s.creadoEn.year}', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    tooltip: 'Editar',
                                    onPressed: () => _editSeguimiento(s),
                                    style: IconButton.styleFrom(
                                      foregroundColor: cs.primary,
                                      padding: const EdgeInsets.all(4),
                                      minimumSize: const Size(28, 28),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _deleteSeguimiento(s),
                                    style: IconButton.styleFrom(
                                      foregroundColor: cs.error,
                                      padding: const EdgeInsets.all(4),
                                      minimumSize: const Size(28, 28),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                  const SizedBox(height: 20),
                  Text('AGREGAR SEGUIMIENTO', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8, color: cs.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _obsCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Observación', hintText: 'Describe el avance del tratamiento...'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitting ? null : _addSeguimiento,
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Agregar seguimiento'),
                  ),
                ],
              ),
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
          Text(value, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}