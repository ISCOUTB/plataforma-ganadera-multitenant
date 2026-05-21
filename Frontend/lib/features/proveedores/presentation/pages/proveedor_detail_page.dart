import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/datasources/proveedores_remote_datasource.dart';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedores_repository.dart';

class ProveedorDetailPage extends StatefulWidget {
  final int proveedorId;
  const ProveedorDetailPage({super.key, required this.proveedorId});

  @override
  State<ProveedorDetailPage> createState() => _ProveedorDetailPageState();
}

class _ProveedorDetailPageState extends State<ProveedorDetailPage> {
  Proveedor? _proveedor;
  List<Map<String, dynamic>> _alimentos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final p = await getIt<ProveedoresRepository>().getOne(widget.proveedorId);
    final a = await getIt<ProveedoresRemoteDataSource>().getAlimentos();
    if (!mounted) return;
    setState(() { _proveedor = p; _alimentos = a; _loading = false; });
  }

  Future<void> _addPrecio() async {
    String? alimentoId;
    final precioCtrl = TextEditingController();
    final unidadCtrl = TextEditingController();
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Agregar precio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: alimentoId,
                decoration: const InputDecoration(labelText: 'Alimento'),
                items: _alimentos.map((a) => DropdownMenuItem(
                  value: a['pk_id_alimento'] as String,
                  child: Text(a['tipo_alimento'] as String),
                )).toList(),
                onChanged: (v) => setStateDialog(() => alimentoId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: precioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unidadCtrl,
                decoration: const InputDecoration(labelText: 'Unidad (ej: kg, bulto)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                confirmed = true;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed && alimentoId != null && precioCtrl.text.isNotEmpty) {
      await getIt<ProveedoresRepository>().addPrecio(widget.proveedorId, {
        'fk_id_alimento': alimentoId,
        'precio': double.parse(precioCtrl.text),
        if (unidadCtrl.text.isNotEmpty) 'unidad': unidadCtrl.text.trim(),
      });
      if (!mounted) return;
      await _load();
    }
  }

  Future<void> _deletePrecio(ProveedorPrecio precio) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar precio'),
        content: const Text('¿Seguro que quieres eliminar este precio?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { confirmed = true; Navigator.of(dialogContext).pop(); },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed) {
      await getIt<ProveedoresRepository>().deletePrecio(precio.id);
      if (!mounted) return;
      await _load();
    }
  }

  Future<void> _delete() async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: const Text('¿Seguro que quieres eliminar este proveedor?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { confirmed = true; Navigator.of(dialogContext).pop(); },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed) {
      await getIt<ProveedoresRepository>().delete(widget.proveedorId);
      if (!mounted) return;
      context.pop();
    }
  }

  String _nombreAlimento(String id) {
    try {
      return _alimentos.firstWhere((a) => a['pk_id_alimento'] == id)['tipo_alimento'] as String;
    } catch (_) {
      return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Scaffold(body: AppLoading());

    final p = _proveedor!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SectionHeader(title: p.nombre, subtitle: 'Detalle del proveedor', showBack: true),
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
                        if (p.contacto != null) _InfoRow(label: 'Contacto', value: p.contacto!),
                        if (p.telefono != null) _InfoRow(label: 'Teléfono', value: p.telefono!),
                        if (p.email != null) _InfoRow(label: 'Email', value: p.email!),
                        if (p.direccion != null) _InfoRow(label: 'Dirección', value: p.direccion!),
                        if (p.notas != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                            child: Text(p.notas!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PRECIOS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8, color: cs.onSurfaceVariant)),
                      TextButton.icon(
                        onPressed: _addPrecio,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (p.precios.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Sin precios registrados', style: TextStyle(color: cs.onSurfaceVariant)),
                    ))
                  else
                    ...p.precios.map((precio) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(left: BorderSide(color: cs.primary, width: 3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_nombreAlimento(precio.fkIdAlimento), style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  '\$${precio.precio.toStringAsFixed(2)}${precio.unidad != null ? ' / ${precio.unidad}' : ''}',
                                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => _deletePrecio(precio),
                            style: IconButton.styleFrom(foregroundColor: cs.error),
                          ),
                        ],
                      ),
                    )),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/inventory/proveedores/${p.id}/edit').then((_) => _load()),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar proveedor'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Eliminar proveedor'),
                    style: ElevatedButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
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