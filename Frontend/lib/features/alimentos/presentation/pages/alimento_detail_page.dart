import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../proveedores/data/datasources/proveedores_remote_datasource.dart';
import '../../../proveedores/domain/entities/proveedor.dart';

class AlimentoDetailPage extends StatefulWidget {
  final String alimentoId;
  final String tipoAlimento;
  const AlimentoDetailPage({super.key, required this.alimentoId, required this.tipoAlimento});

  @override
  State<AlimentoDetailPage> createState() => _AlimentoDetailPageState();
}

class _AlimentoDetailPageState extends State<AlimentoDetailPage> {
  List<ProveedorPrecio> _precios = [];
  bool _loading = true;
  final _fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final data = await getIt<ProveedoresRemoteDataSource>().getComparador(widget.alimentoId);
    if (!mounted) return;
    setState(() { _precios = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SectionHeader(
              title: widget.tipoAlimento,
              subtitle: 'Comparador de precios',
              showBack: true,
            ),
            Expanded(
              child: _loading
                  ? const AppLoading()
                  : _precios.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.store_outlined, size: 64, color: cs.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text('Ningún proveedor vende este alimento', style: TextStyle(color: cs.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Text('Agrega precios desde el módulo de proveedores', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          children: [
                            Text('PROVEEDORES', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8, color: cs.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text('Ordenados de menor a mayor precio', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            const SizedBox(height: 16),
                            ..._precios.asMap().entries.map((entry) {
                              final i = entry.key;
                              final precio = entry.value;
                              final esMejor = i == 0;
                              final color = esMejor ? cs.primary : cs.onSurface;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: esMejor ? cs.primary.withValues(alpha: 0.06) : cs.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: esMejor ? cs.primary : cs.outlineVariant,
                                    width: esMejor ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: esMejor ? cs.primary : cs.surfaceContainerHighest,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: esMejor
                                            ? Icon(Icons.star_rounded, color: cs.onPrimary, size: 20)
                                            : Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            precio.proveedor?.nombre ?? 'Proveedor',
                                            style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
                                          ),
                                          if (precio.unidad != null)
                                            Text(precio.unidad!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _fmt.format(precio.precio),
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color),
                                        ),
                                        if (esMejor)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(999)),
                                            child: Text('Mejor precio', style: TextStyle(color: cs.onPrimary, fontSize: 10, fontWeight: FontWeight.w700)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}