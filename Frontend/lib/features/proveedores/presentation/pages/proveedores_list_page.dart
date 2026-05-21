import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedores_repository.dart';

class ProveedoresListPage extends StatefulWidget {
  const ProveedoresListPage({super.key});

  @override
  State<ProveedoresListPage> createState() => _ProveedoresListPageState();
}

class _ProveedoresListPageState extends State<ProveedoresListPage> {
  List<Proveedor> _proveedores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final data = await getIt<ProveedoresRepository>().getAll();
    if (!mounted) return;
    setState(() { _proveedores = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const SectionHeader(
                  title: 'Proveedores',
                  subtitle: 'Gestión de proveedores de alimentos',
                  showBack: true,
                ),
                Expanded(
                  child: _loading
                      ? const AppLoading()
                      : _proveedores.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(PhosphorIcons.truck(PhosphorIconsStyle.bold), size: 64, color: cs.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                  Text('No hay proveedores registrados', style: TextStyle(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                                itemCount: _proveedores.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final p = _proveedores[i];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: cs.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(PhosphorIcons.truck(PhosphorIconsStyle.bold), color: cs.primary, size: 22),
                                      ),
                                      title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      subtitle: Text(p.telefono ?? p.contacto ?? 'Sin contacto'),
                                      trailing: Text('${p.precios.length} precios', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                                      onTap: () => context.push('/money/proveedores/${p.id}').then((_) => _load()),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => context.push('/money/proveedores/new').then((_) => _load()),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}