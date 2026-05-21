import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../proveedores/data/datasources/proveedores_remote_datasource.dart';
import '../../../proveedores/domain/entities/proveedor.dart';

class ProveedoresResumenCard extends StatefulWidget {
  const ProveedoresResumenCard({super.key});

  @override
  State<ProveedoresResumenCard> createState() => _ProveedoresResumenCardState();
}

class _ProveedoresResumenCardState extends State<ProveedoresResumenCard> {
  List<_AlimentoResumen> _resumenes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ds = getIt<ProveedoresRemoteDataSource>();
      final alimentos = await ds.getAlimentos();
      final resumenes = <_AlimentoResumen>[];

      for (final alimento in alimentos.take(4)) {
        final id = alimento['pk_id_alimento'] as String;
        final nombre = alimento['tipo_alimento'] as String;
        final precios = await ds.getComparador(id);
        if (precios.isNotEmpty) {
          resumenes.add(_AlimentoResumen(
            id: id,
            nombre: nombre,
            mejorPrecio: precios.first,
            totalProveedores: precios.length,
          ));
        }
      }

      if (!mounted) return;
      setState(() { _resumenes = resumenes; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(PhosphorIcons.truck(PhosphorIconsStyle.fill), color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Mejores precios', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
              ),
              TextButton(
                onPressed: () => context.push('/money/proveedores'),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          Text('Proveedor más económico por alimento', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (_resumenes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin datos de proveedores', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            )
          else
            ..._resumenes.map((r) => InkWell(
              onTap: () => context.push('/money/alimentos/${r.id}/detalle?nombre=${Uri.encodeComponent(r.nombre)}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.star_rounded, color: cs.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.nombre, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(r.mejorPrecio.proveedor?.nombre ?? '—', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fmt(r.mejorPrecio.precio),
                          style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary, fontSize: 14),
                        ),
                        Text('${r.totalProveedores} proveedores', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.05, end: 0);
  }

  String _fmt(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}K';
    return '\$${v.toStringAsFixed(0)}';
  }
}

class _AlimentoResumen {
  final String id;
  final String nombre;
  final ProveedorPrecio mejorPrecio;
  final int totalProveedores;

  _AlimentoResumen({required this.id, required this.nombre, required this.mejorPrecio, required this.totalProveedores});
}