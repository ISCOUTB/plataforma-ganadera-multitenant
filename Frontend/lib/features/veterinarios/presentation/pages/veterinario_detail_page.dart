import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/veterinario.dart';
import '../../domain/repositories/veterinarios_repository.dart';

class VeterinarioDetailPage extends StatefulWidget {
  final int veterinarioId;
  const VeterinarioDetailPage({super.key, required this.veterinarioId});

  @override
  State<VeterinarioDetailPage> createState() => _VeterinarioDetailPageState();
}

class _VeterinarioDetailPageState extends State<VeterinarioDetailPage> {
  Veterinario? _vet;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await getIt<VeterinariosRepository>().getOne(widget.veterinarioId);
    if (!mounted) return;
    setState(() { _vet = v; _loading = false; });
  }

  Future<void> _delete() async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar veterinario'),
        content: const Text('¿Seguro que quieres eliminar este veterinario? Esta acción no se puede deshacer.'),
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
      await getIt<VeterinariosRepository>().delete(_vet!.id);
      if (!mounted) return;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Scaffold(body: AppLoading());

    final v = _vet!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SectionHeader(title: v.nombre, subtitle: v.especialidad ?? 'Veterinario', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: cs.primary.withValues(alpha: 0.12),
                          child: Icon(PhosphorIcons.stethoscope(PhosphorIconsStyle.bold), color: cs.primary, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text(v.nombre, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        if (v.especialidad != null)
                          Text(v.especialidad!, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(height: 20),
                        if (v.telefono != null)
                          _ContactRow(icon: Icons.phone_outlined, value: v.telefono!),
                        if (v.email != null)
                          _ContactRow(icon: Icons.email_outlined, value: v.email!),
                        if (v.notas != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(v.notas!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/health/veterinarios/${v.id}/edit'),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar veterinario'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Eliminar veterinario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
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

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 10),
          Text(value, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}