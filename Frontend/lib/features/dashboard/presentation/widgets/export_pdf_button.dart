import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/dashboard_summary.dart';

/// Botón que genera y descarga un PDF con el reporte del dashboard.
class ExportPdfButton extends StatelessWidget {
  final DashboardSummary data;
  final String userName;
  final String tenantId;

  const ExportPdfButton({
    super.key,
    required this.data,
    required this.userName,
    required this.tenantId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _generateAndPrint(context),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.download_rounded, color: cs.primary, size: 22),
        ),
      ),
    );
  }

  Future<void> _generateAndPrint(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generando reporte PDF...'),
        backgroundColor: cs.primary,
        duration: const Duration(seconds: 2),
      ),
    );

    final pdf = pw.Document();
    final now = DateFormat.yMMMMd('es').format(DateTime.now());
    final fmt = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    final navy = PdfColor.fromHex('#1E3A5F');
    final blue = PdfColor.fromHex('#3B82F6');
    final green = PdfColor.fromHex('#16A34A');
    final red = PdfColor.fromHex('#EF4444');
    final gray = PdfColor.fromHex('#64748B');
    final lightBg = PdfColor.fromHex('#F8FAFC');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _buildHeader(ctx, navy, now),
        footer: (ctx) => _buildFooter(ctx, gray),
        build: (ctx) => [
          // Inventario
          _sectionTitle('Inventario', navy),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _kpiBox('Total animales', '${data.demography.total}', navy),
              _kpiBox('Machos', '${data.genderSplit.machos}', blue),
              _kpiBox('Hembras', '${data.genderSplit.hembras}',
                  PdfColor.fromHex('#EC4899')),
              _kpiBox('Potreros', '${data.allPotreros.length}', green),
            ],
          ),
          pw.SizedBox(height: 20),

          // Demografía
          _sectionTitle('Demografía del hato', navy),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _barItem('Producción', data.demography.produccionPct, navy),
              pw.SizedBox(width: 12),
              _barItem('Crecimiento', data.demography.crecimientoPct, blue),
              pw.SizedBox(width: 12),
              _barItem('Secas', data.demography.secasPct,
                  PdfColor.fromHex('#F59E0B')),
            ],
          ),
          pw.SizedBox(height: 20),

          // Finanzas
          _sectionTitle('Resumen financiero', navy),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _kpiBox('Ingresos', fmt.format(data.financesSummary.totalIngresos),
                  green),
              _kpiBox(
                  'Gastos', fmt.format(data.financesSummary.totalGastos), red),
              _kpiBox(
                  'Balance', fmt.format(data.financesSummary.balance), navy),
            ],
          ),
          pw.SizedBox(height: 20),

          // Ocupación del terreno
          _sectionTitle('Ocupación del terreno', navy),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _kpiBox('Usado', '${data.occupancy.usedHectares} ha', blue),
              pw.SizedBox(width: 12),
              _kpiBox(
                  'Total', '${data.occupancy.totalHectares} ha', gray),
              pw.SizedBox(width: 12),
              _kpiBox('Ocupación', '${data.occupancy.usedPct}%',
                  data.occupancy.usedPct >= 70 ? red : green),
            ],
          ),
          pw.SizedBox(height: 20),

          // Tabla de potreros
          _sectionTitle('Detalle de potreros', navy),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            headers: ['Potrero', 'Capacidad', 'Animales', '% Ocup.', 'Área'],
            data: data.allPotreros
                .map((p) => [
                      p.nombre,
                      '${p.capacidad}',
                      '${p.ocupacion}',
                      '${(p.pct * 100).round()}%',
                      '${p.area} ha',
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 20),

          // Alertas
          if (data.criticalAlerts.isNotEmpty) ...[
            _sectionTitle(
                'Alertas críticas (${data.criticalAlerts.length})', red),
            pw.SizedBox(height: 8),
            ...data.criticalAlerts.map((a) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 6,
                        height: 6,
                        decoration: pw.BoxDecoration(
                          color: a.urgency == AlertUrgency.high ? red : blue,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          '${a.animalId} — ${a.reason}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'FarmLink_Reporte_${DateTime.now().toIso8601String().substring(0, 10)}',
    );
  }

  pw.Widget _buildHeader(pw.Context ctx, PdfColor navy, String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FarmLink',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: navy,
                ),
              ),
              pw.Text(
                'Reporte del Dashboard',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColor.fromHex('#64748B'),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(date,
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Tenant: $tenantId',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Usuario: $userName',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context ctx, PdfColor gray) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('FarmLink © 2026',
              style: pw.TextStyle(fontSize: 8, color: gray)),
          pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: gray)),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    );
  }

  pw.Widget _kpiBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F8FAFC'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 8, color: PdfColor.fromHex('#64748B'))),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _barItem(String label, int pct, PdfColor color) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label: $pct%',
              style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Stack(
            children: [
              pw.Container(
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E2E8F0'),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(99)),
                ),
              ),
              pw.Container(
                height: 8,
                width: 80.0 * (pct / 100).clamp(0, 1),
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(99)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
