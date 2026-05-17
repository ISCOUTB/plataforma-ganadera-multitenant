import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    setState(() { _cita = c; _loading = false; });
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
          Expanded(child: Text(value, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
